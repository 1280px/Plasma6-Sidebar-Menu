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

    property int visible_items: (
        (Plasmoid.configuration.showHeader ? headingSvg.height : 0) // Header
        + (searchPosition != 2 ? 44 : 0) // Search
        + (kicker.view_any_controls == true ? footer.height : 0) // Footer
        + Kirigami.Units.gridUnit
    )
    property int cuadricula_hg: (
        kicker.availableScreenRect.height
        - rootItem.visible_items
        - Plasmoid.containment.containmentDisplayHints * ( // Floating mode
            Plasmoid.formFactor === PlasmaCore.Types.Vertical ? 2 : 3
        ) // (account for panel height for a horizontal mode)
        - (Plasmoid.formFactor === PlasmaCore.Types.Vertical ? 9 : -9) // ???
    )

    property int calc_width: (
        (kicker.cellSizeWidth * Plasmoid.configuration.numberColumns)
        + Kirigami.Units.gridUnit + 4
        // + (Plasmoid.formFactor !== PlasmaCore.Types.Vertical ? 4 : 0) // ????
    )
    property int calc_height: (
        cuadricula_hg + rootItem.visible_items
    )

    property int dynamicColumns: Math.floor(rootItem.calc_width / kicker.cellSizeWidth)
    property int dynamicRows: Math.ceil(kicker.count / dynamicColumns)

    Layout.maximumWidth: calc_width
    Layout.minimumWidth: calc_width
    Layout.minimumHeight: calc_height
    Layout.maximumHeight: calc_height

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
                ? encabezado.height + Kirigami.Units.smallSpacing
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
        visible: kicker.view_any_controls
        width: (
            parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
        )
        height: (
            footer.Layout.preferredHeight + Kirigami.Units.smallSpacing * 7
        )
        x: backgroundSvg.margins.left
        y: parent.height + Kirigami.Units.smallSpacing * 2 // - (footer.height + Kirigami.Units.smallSpacing)
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
        Layout.preferredHeight: rootItem.calc_height

        Item {
            id: encabezado
            width: rootItem.calc_width
            Layout.preferredHeight: 130
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
            Layout.preferredHeight: rootItem.searchPosition == 0 ? 40 : 0
            visible: rootItem.searchPosition == 0
        }

        // Grid
        Item {
            id: gridComponent
            width: rootItem.calc_width
            Layout.preferredHeight: (
                resizeHeight() == 0
                    ? rootItem.cuadricula_hg
                    : resizeHeight() - rootItem.visible_items
            )

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
                height: (
                    rootItem.resizeHeight() == 0
                        ? rootItem.cuadricula_hg
                        : rootItem.resizeHeight() - rootItem.visible_items
                )
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
                        height: (
                            rootItem.resizeHeight() == 0
                                ? rootItem.cuadricula_hg
                                : rootItem.resizeHeight() - rootItem.visible_items
                        )
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
                        height: (
                            rootItem.resizeHeight() == 0
                                ? rootItem.cuadricula_hg
                                : rootItem.resizeHeight() - rootItem.visible_items
                        )
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
            Layout.preferredHeight: rootItem.searchPosition == 1 ? 40 : 0
            visible: rootItem.searchPosition == 1
        }

        Item {
            id: footer
            Layout.preferredHeight: 20
            visible: Plasmoid.configuration.showFooter && kicker.view_any_controls
            width: rootItem.calc_width

            Loader {
                id: foot_
                sourceComponent: footerComponent
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

    function resizeWidth() {
        var screenAvail = kicker.availableScreenRect;
        var screenGeom = kicker.screenGeometry;
        var screen = Qt.rect(
            screenAvail.x + screenGeom.x,
            screenAvail.y + screenGeom.y,
            screenAvail.width,
            screenAvail.height
        );
        if (
            screen.width > (
                kicker.cellSizeWidth * Plasmoid.configuration.numberColumns
                + Kirigami.Units.gridUnit
            )
        ) {
            return 0;
        } else {
            return screen.width;
        }
    }
    function resizeHeight() {
        var screenAvail = kicker.availableScreenRect;
        var screenGeom = kicker.screenGeometry;
        var screen = Qt.rect(
            screenAvail.x + screenGeom.x,
            screenAvail.y + screenGeom.y,
            screenAvail.width,
            screenAvail.height
        );
        if (
            screen.height > (
                kicker.cellSizeHeight // * Plasmoid.configuration.numberRows
                + rootItem.visible_items
                + Kirigami.Units.gridUnit * 1.5
            )
        ) {
            return 0;
        } else {
            return screen.height;
        }
    }

    function updateLayouts() {
        userShape = calculateUserShape(Plasmoid.configuration.userShape);
        searchPosition = Plasmoid.configuration.showSearch;
        calculateSearchParent();
    }
    function calculateUserShape(shape) {
        switch (shape) {
        case 2:
            return 0;
        case 1:
            return 8;
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
