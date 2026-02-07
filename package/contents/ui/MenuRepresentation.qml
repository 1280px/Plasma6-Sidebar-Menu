/*   Copyright (C) 2024-2024 by Randy Abiel Cabrera                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          */

import QtQml 2.15
import QtQuick 2.4
import QtQuick.Layouts 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kirigami 2.0 as Kirigami
// import org.kde.plasma.private.quicklaunch 1.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker

FocusScope {
    id: rootItem
    focus: true

    property int userShape: calculateUserShape(Plasmoid.configuration.userShape)
    property int searchPosition: Plasmoid.configuration.showSearch

    property int itemsHeight: (
        (Plasmoid.configuration.showHeader ? (header.height) : 0) // Header
        + (searchPosition !== 2 ? 30 : -2) // Search field
        + (searchPosition === 1 ? 5 : 0) // Gap for search @ footer
        + (Plasmoid.configuration.showFooter
            ? (footer.height * 2 + Kirigami.Units.smallSpacing * 2.5)
            : 0) // Footer
    )
    property int gridsHeight: (
        kicker.availableScreenRect.height
        - rootItem.itemsHeight
        - (Plasmoid.formFactor == PlasmaCore.Types.Vertical
            ? ( // In V mode, we add floating mode margins on top and bottom
                Plasmoid.containmentDisplayHints * 2
                + 9 // Remove gap for vertical panels
            )
            : ( // In H mode, we want to reverse logic, so plasmoid fills 100% unless floating
                Plasmoid.containmentDisplayHints
                    ? Kirigami.Units.smallSpacing * 5
                    : - 6 // Add tiny gap to prevent overlapping with horizontal panel
            )
        )
    )

    property int spaceWidth: (
        (kicker.cellSizeWidth * Plasmoid.configuration.numberColumns)
        + Kirigami.Units.smallSpacing + Kirigami.Units.gridUnit
    )
    property int spaceHeight: (
        gridsHeight + rootItem.itemsHeight
    )

    property int dynamicColumns: Math.floor(rootItem.spaceWidth / kicker.cellSizeWidth)
    property int dynamicRows: Math.ceil(kicker.count / dynamicColumns)

    Layout.minimumWidth: spaceWidth
    Layout.maximumWidth: spaceWidth

    KCoreAddons.KUser {
        id: kuser
    }

    // Graphics
    KSvg.FrameSvgItem {
        id: headingSvg
        width: (
            parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
        )
        height: (
            Plasmoid.configuration.showHeader
                ? 132 + Kirigami.Units.smallSpacing
                : Kirigami.Units.smallSpacing
        )
        y: -backgroundSvg.margins.top
        x: -backgroundSvg.margins.left
        imagePath: "widgets/plasmoidheading"
        prefix: "header"
        opacity: Plasmoid.configuration.transparencyHeader * 0.01
        visible: Plasmoid.configuration.showHeader
    }

    KSvg.FrameSvgItem {
        id: footerSvg
        visible: Plasmoid.configuration.showFooter
        width: (
            parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
        )
        height: (
            footer.Layout.preferredHeight * 2 + Kirigami.Units.smallSpacing * 3
        )
        x: backgroundSvg.margins.left
        y: parent.height + Kirigami.Units.smallSpacing // - (footer.height + Kirigami.Units.smallSpacing)
        imagePath: "widgets/plasmoidheading"
        prefix: "header"
        opacity: Plasmoid.configuration.transparencyFooter * 0.01
        transform: Rotation {
            angle: 180
            origin.x: width / 2
        }
    }


    // Search loader
    Loader {
        id: searchLoader
        sourceComponent: searchComponent
        visible: rootItem.searchPosition != 2
    }

    // DEBUGGING
    // Rectangle {
    //     width: 200
    //     height: 20
    //     color: '#fff'
    //     z: 999
    //     opacity: 0.66

    //     Text {
    //         id: count
    //         text: kicker.keyIn
    //         color: '#000'
    //     }
    // }

    // Menu container
    ColumnLayout {
        id: container
        Layout.preferredHeight: rootItem.spaceHeight
        spacing: 0

        Item {
            id: header
            width: rootItem.spaceWidth
            Layout.preferredHeight: (
                132 + (rootItem.searchPosition == 0 ? Kirigami.Units.smallSpacing : 0)
            )
            visible: Plasmoid.configuration.showHeader

            Loader {
                id: head_
                sourceComponent: headComponent

                onLoaded: {
                    var pinButton = head_.item.pinButton;
                    if (!activeFocus && kicker.hideOnWindowDeactivate === false) {
                        if (!pinButton.checked) {
                            turnclose();
                        }
                    }
                }
            }
        }

        // Header slot for search
        Item {
            id: searchHeader
            visible: rootItem.searchPosition == 0
            Layout.preferredHeight: rootItem.searchPosition == 0 ? 32 : 0
        }

        Item {
            id: gridComponent
            width: rootItem.spaceWidth
            Layout.preferredHeight: rootItem.gridsHeight

            // Grid for favorites
            ItemGridView {
                id: globalFavoritesGrid
                visible: (
                    (Plasmoid.configuration.showFavoritesFirst || kicker.showFavorites)
                    && (!kicker.searching && kicker.showFavorites)
                )
                focus: true
                dragEnabled: true
                dropEnabled: true
                width: rootItem.width
                height: rootItem.gridsHeight
                cellWidth: kicker.cellSizeWidth
                cellHeight: kicker.cellSizeHeight
                iconSize: kicker.iconSize

                onKeyNavUp: searchLoader.item.gofocus()

                // Favorites key event
                Keys.onPressed: (event) => {
                    kicker.keyIn = "Favorites: " + event.key;
                    if (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.ShiftModifier) {
                        searchLoader.item.gofocus();
                        return;
                    } else if (event.key === Qt.Key_Tab) {
                        event.accepted = true;
                        searchLoader.item.gofocus();
                    } else if (event.key === Qt.Key_Escape) {
                        event.accepted = true;
                        rootItem.turnclose();
                    }
                }
            }

            Item {
                id: mainGrids
                visible: (
                    (!Plasmoid.configuration.showFavoritesFirst && !kicker.showFavorites)
                    || kicker.searching || !kicker.showFavorites // TODO
                )
                width: rootItem.width

                // Container used by both apps and search
                Item {
                    id: mainColumn
                    width: rootItem.width
                    property Item visibleGrid: allAppsGrid

                    // Grid for apps
                    ItemGridView {
                        id: allAppsGrid
                        width: rootItem.width
                        height: rootItem.gridsHeight
                        cellWidth: kicker.cellSizeWidth
                        cellHeight: kicker.cellSizeHeight
                        iconSize: kicker.iconSize
                        enabled: (opacity == 1) ? 1 : 0
                        z: enabled ? 5 : -1
                        dropEnabled: false
                        dragEnabled: false
                        opacity: kicker.searching ? 0 : 1

                        onOpacityChanged: {
                            if (opacity == 1) {
                                mainColumn.visibleGrid = allAppsGrid;
                            }
                        }
                        onKeyNavUp: searchLoader.item.gofocus()
                    }

                    // Grid for search results
                    ItemMultiGridView {
                        id: runnerGrid
                        width: rootItem.width
                        height: rootItem.gridsHeight
                        cellWidth: kicker.cellSizeWidth
                        cellHeight: kicker.cellSizeHeight
                        enabled: (opacity == 1) ? 1 : 0
                        z: enabled ? 5 : -1
                        model: runnerModel
                        grabFocus: true
                        opacity: kicker.searching ? 1 : 0

                        onOpacityChanged: {
                            if (opacity == 1) {
                                mainColumn.visibleGrid = runnerGrid;
                            }
                        }
                        onKeyNavUp: searchLoader.item.gofocus()
                    }

                    // Grid activation function
                    function tryActivate(row, col) {
                        if (visibleGrid) {
                            visibleGrid.tryActivate(row, col);
                        }
                    }

                    // Keys that are reactionary to events
                    Keys.onPressed: (event) => {
                        kicker.keyIn = "Grids or Search: " + event.key;
                        if (
                            (event.modifiers & Qt.ControlModifier)
                            || (event.modifiers & Qt.ShiftModifier)
                        ) {
                            searchLoader.item.gofocus();
                            return;
                        }
                        if (event.key === Qt.Key_Tab) {
                            event.accepted = true;
                            searchLoader.item.gofocus();
                        } else if (event.key === Qt.Key_Backspace) {
                            event.accepted = true;
                            if (kicker.searching) {
                                searchLoader.item.backspace();
                            }
                            searchLoader.item.gofocus();
                        } else if (event.key === Qt.Key_Escape) {
                            event.accepted = true;
                            (kicker.searching) ? rootItem.reset() : rootItem.turnclose();
                        } else if (event.text !== "") {
                            event.accepted = true;
                            searchLoader.item.appendText(event.text);
                        }
                    }
                }
            }
        }

        // Footer slot for search
        Item {
            id: searchFooter
            visible: rootItem.searchPosition == 1
            Layout.preferredHeight: rootItem.searchPosition == 1 ? 32 : 0
        }

        Item {
            id: footer
            Layout.preferredHeight: Kirigami.Units.smallSpacing * 4
            visible: Plasmoid.configuration.showFooter
            width: rootItem.spaceWidth

            ColumnLayout {
                width: rootItem.spaceWidth
                spacing: 0

                Item {
                    Layout.preferredHeight: (
                        Math.ceil(
                            Kirigami.Units.smallSpacing * 2
                            + (searchPosition === 1 ? 5 : 0)
                        ) - 0.666
                    )
                }

                Loader {
                    id: footerContent
                    sourceComponent: footerComponent
                    width: rootItem.spaceWidth
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    // Key presses in menu representation
    Keys.onPressed: (event) => {
        kicker.keyIn = "Menu Representation: " + event.key;

        // Assume all events are accepted unless proven otherwise
        event.accepted = true;

        if (event.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) {
            searchLoader.item.gofocus();
            return;
        }

        switch (event.key) {
            case Qt.Key_Escape:
                turnclose();
                break;
            case Qt.Key_Backspace:
                searchLoader.item.backspace();
                break;
            case Qt.Key_Tab:
            case Qt.Key_Backtab:
            case Qt.Key_Down:
            case Qt.Key_Up:
            case Qt.Key_Left:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Right:
                reset();
                break;
            default:
                (/^[a-zA-Z0-9]$/.test(event.text))
                    ? searchLoader.item.appendText(event.text)
                    : reset();
                break;
        }

        searchLoader.item.gofocus();
    }

    Component {
        id: headComponent
        Head { }
    }
    Component {
        id: footerComponent
        Footer { }
    }
    Component {
        id: searchComponent
        Search { }
    }

    function turnclose() {
        searchLoader.item.emptysearch();

        kicker.searching = false;     
        kicker.showFavorites
            ? globalFavoritesGrid.tryActivate(0, 0)
            : mainColumn.tryActivate(0, 0);
        kicker.expanded = false;
    }
    function reset() {
        searchLoader.item.emptysearch();

        kicker.searching = false;
        kicker.showFavorites
            ? globalFavoritesGrid.tryActivate(0, 0)
            : mainColumn.tryActivate(0, 0);
    }

    function updateLayouts() {
        userShape = calculateUserShape(Plasmoid.configuration.userShape);
        searchPosition = Plasmoid.configuration.showSearch;
        calculateSearchParent();
    }
    function calculateUserShape(shape) {
        switch (shape) {
        case 2:
            return 8;
        case 1:
            return (kicker.sizeImage * 0.85) / 4;
        case 0:
        default:
            return (kicker.sizeImage * 0.85) / 2;
        }
    }
    function calculateSearchParent() {
        searchLoader.parent = (
            (searchPosition == 0)
                ? searchHeader
                : (searchPosition == 1)
                    ? searchFooter
                    : rootItem
        );
    }
    function setModels() {
        globalFavoritesGrid.model = globalFavorites;
        allAppsGrid.model = rootModel.modelForRow(0);
    }

    onSpaceHeightChanged: {
        Layout.minimumHeight = spaceHeight + 1; // Prevent overflow from breaking layout
        Layout.maximumHeight = spaceHeight + 1; // Prevent overflow from breaking layout

        updateLayouts();
    }

    onActiveFocusChanged: {
        if (
            (!activeFocus && kicker.hideOnWindowDeactivate === false)
            && head_.item && head_.item.pinButton && !head_.item.pinButton.checked
        ) {
            turnclose();
        }
    }
    onSearchPositionChanged: calculateSearchParent()

    Component.onCompleted: {
        rootModel.refreshed.connect(setModels);
        rootModel.refresh();

        calculateSearchParent();

        kicker.showFavorites
            ? globalFavoritesGrid.tryActivate(0, 0)
            : mainColumn.tryActivate(0, 0);
    }
}
