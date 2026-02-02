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

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons
// import org.kde.plasma.private.quicklaunch 1.0
import org.kde.ksvg 1.0 as KSvg
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQml 2.15
import org.kde.kirigami 2.0  as Kirigami
import org.kde.plasma.plasmoid 2.0


FocusScope
{
    id: rootItem
    property bool searchvisible : Plasmoid.configuration.showSearch
    property int visible_items: (Plasmoid.configuration.showInfoUser ? headingSvg.height : 0) + (rootItem.searchvisible == true ? rowSearchField.height : 0) + ( kicker.view_any_controls == true ? footer.height : 0)+ Kirigami.Units.gridUnit
    property int cuadricula_hg : (kicker.cellSizeHeight *  Plasmoid.configuration.numberRows)
    property int calc_width : (kicker.cellSizeWidth *  Plasmoid.configuration.numberColumns) + Kirigami.Units.gridUnit
    property int calc_height : cuadricula_hg  + (rootItem.visible_items)
    property int userShape : calculateUserShape(Plasmoid.configuration.userShape);
    property int space_width : resizeWidth()  == 0 ? rootItem.calc_width : resizeWidth()
    property int space_height : resizeHeight() == 0 ? rootItem.calc_height  : resizeHeight()
    property int dynamicColumns : Math.floor( rootItem.space_width  / kicker.cellSizeWidth)
    property int dynamicRows : Math.ceil(kicker.count / dynamicColumns)

    Layout.maximumWidth: space_width
    Layout.minimumWidth: space_width
    Layout.minimumHeight:space_height
    Layout.maximumHeight:space_height
    focus: true
    KCoreAddons.KUser { id: kuser }

    // Graphics
    KSvg.FrameSvgItem
    {
        id : headingSvg
        width: parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
        height: Plasmoid.configuration.showInfoUser ? encabezado.height + Kirigami.Units.smallSpacing : Kirigami.Units.smallSpacing
        y: - backgroundSvg.margins.top
        x: - backgroundSvg.margins.left
        imagePath: "widgets/plasmoidheading"
        prefix: "header"
        opacity: Plasmoid.configuration.transparencyHead * 0.01
        visible: Plasmoid.configuration.showInfoUser
    }

    KSvg.FrameSvgItem
    {
        id: footerSvg
        visible: kicker.view_any_controls
        width: parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
        height:footer.Layout.preferredHeight + 2  + Kirigami.Units.smallSpacing * 3
        y: parent.height + Kirigami.Units.smallSpacing * 2 // - (footer.height + Kirigami.Units.smallSpacing)
        x: backgroundSvg.margins.left
        imagePath: "widgets/plasmoidheading"
        prefix: "header"
        transform: Rotation { angle: 180; origin.x: width / 2; }
        opacity: Plasmoid.configuration.transparencyFooter * 0.01
    }

    // DEBUGGING
    Text
    {
        id: count
        text: kicker.keyIn
    }

    // Menu container
    ColumnLayout
    {
        id:container
        Layout.preferredHeight: rootItem.space_height

        // Heading
        Item
        {
            id: encabezado
            width: rootItem.space_width
            Layout.preferredHeight: 130
            visible:  Plasmoid.configuration.showInfoUser
            Loader
            {
                   id: head_
                   sourceComponent: headComponent
                   onLoaded:
                   {
                       var pinButton = head_.item.pinButton;

                       if (!activeFocus && kicker.hideOnWindowDeactivate === false)
                       {
                           if (!pinButton.checked) {turnclose();}
                       }
                   }
            }
        }

        // Grid
        Item
        {
            id: gridComponent
            width: rootItem.space_width
            Layout.preferredHeight:(resizeHeight() == 0 ? rootItem.cuadricula_hg  : resizeHeight() -rootItem.visible_items)

            // Grid for favourites
            ItemGridView
            {
                id: globalFavoritesGrid
                visible: (Plasmoid.configuration.showFavoritesFirst || kicker.showFavorites)  && (!kicker.searching && kicker.showFavorites)
                dragEnabled: true
                dropEnabled: true
                height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
                width: rootItem.width
                focus: true
                cellWidth:   kicker.cellSizeWidth
                cellHeight:  kicker.cellSizeHeight
                iconSize:    kicker.iconSize
                onKeyNavUp:  searchLoader.item.gofocus();

                // Favourites key event
                Keys.onPressed:(event) =>
                {
                    kicker.keyIn = "Favourites: " + event.key;
                    if (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.ShiftModifier)
                    {
                        searchLoader.item.gofocus();
                        return
                    }
                    else if (event.key === Qt.Key_Tab)
                    {
                        event.accepted = true;
                        searchLoader.item.gofocus();
                    }
                    else if (event.key === Qt.Key_Escape)
                    {
                        event.accepted = true;
                        rootItem.turnclose()
                    }
                }
            }

            Item
            {
                id: mainGrids
                visible: (!Plasmoid.configuration.showFavoritesFirst && !kicker.showFavorites ) || kicker.searching || !kicker.showFavorites //TODO
                width: rootItem.width

                // Container used by both apps and search
                Item
                {
                    id: mainColumn
                    width: rootItem.width
                    property Item visibleGrid: allAppsGrid

                    // Grid for apps
                    ItemGridView
                    {
                        id: allAppsGrid
                        width: rootItem.width
                        height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
                        cellWidth:   kicker.cellSizeWidth
                        cellHeight:  kicker.cellSizeHeight
                        iconSize:    kicker.iconSize
                        enabled: (opacity == 1) ? 1 : 0
                        z:  enabled ? 5 : -1
                        dropEnabled: false
                        dragEnabled: false
                        opacity: kicker.searching ? 0 : 1
                        onOpacityChanged: { if (opacity == 1) { mainColumn.visibleGrid = allAppsGrid; } }
                        onKeyNavUp: searchLoader.item.gofocus()
                    }

                    // Grid for search results
                    ItemMultiGridView
                    {
                        id: runnerGrid
                        width: rootItem.width
                        height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
                        cellWidth: kicker.cellSizeWidth
                        cellHeight: kicker.cellSizeHeight
                        enabled: (opacity == 1.0) ? 1 : 0
                        z: enabled ? 5 : -1
                        model: runnerModel
                        grabFocus: true
                        opacity: kicker.searching ? 1.0 : 0.0
                        onOpacityChanged: { if (opacity == 1.0) { mainColumn.visibleGrid = runnerGrid;}}
                        onKeyNavUp: searchLoader.item.gofocus()
                    }

                    // Grid activation function
                    function tryActivate(row, col)
                    {
                        if (visibleGrid)
                        {
                            visibleGrid.tryActivate(row, col);
                        }
                    }

                    // Keys that are reactionary to events
                    Keys.onPressed: (event) =>
                    {
                        kicker.keyIn = "Grids or Search: " + event.key;

                        if (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.ShiftModifier)
                        {searchLoader.item.gofocus();
                            return;
                        }
                        if (event.key === Qt.Key_Tab)
                        {
                            event.accepted = true;
                            searchLoader.item.gofocus();
                        }
                        else if (event.key === Qt.Key_Backspace)
                        {event.accepted = true;
                            if (kicker.searching)
                            {
                                searchLoader.item.backspace();
                            }
                            searchLoader.item.gofocus();
                        }
                        else if (event.key === Qt.Key_Escape)
                        {
                            event.accepted = true;
                            if(kicker.searching){rootItem.reset()}
                            else {rootItem.turnclose();}
                        }
                        else if (event.text !== "")
                        {
                            event.accepted = true;
                            searchLoader.item.appendText(event.text);
                        }
                    }
                }
            }
        }

        Item
        {
            id: rowSearchField
            visible: rootItem.searchvisible
            Layout.preferredHeight:45
            width: rootItem.space_width
            Loader{id: searchLoader
                   sourceComponent: searchComponent}
        }

        Item
        {
            id: footer
            Layout.preferredHeight:25
            visible: kicker.view_any_controls
            width: rootItem.space_width
            Loader
            {id: foot_
             sourceComponent: footerComponent}
        }
    }

    // Press key in menu representation
    Keys.onPressed: (event) =>
    {
        kicker.keyIn = "Menu Representation: " + event.key;

        // Assume all events are accepted prompted otherwise
        event.accepted = true;

        if (event.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) { searchLoader.item.gofocus(); return;}
        switch (event.key)
        {
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
                if (isLetterOrNumber(event.text))
                {
                    searchLoader.item.appendText(event.text);
                }
                else {reset();}
                break;
        }
        searchLoader.item.gofocus();
    }

    Component { id: footerComponent; Footer{} }
    Component { id: searchComponent; Search{} }
    Component { id: headComponent; Head{} }

    function isLetterOrNumber(text) {
        return /^[a-zA-Z0-9]$/.test(text);
    }

    function turnclose()
    {
        searchLoader.item.emptysearch()
        kicker.searching=false;
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(0,0);}
        else {mainColumn.tryActivate(0,0);}
        kicker.expanded = false;
        return
    }
    function reset()
    {
        searchLoader.item.emptysearch()
        kicker.searching=false;
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(0,0);}
        else {mainColumn.tryActivate(0,0);}

    }
    function resizeWidth()
    {
        var screenAvail = kicker.availableScreenRect;
        var screenGeom = kicker.screenGeometry;
        var screen = Qt.rect(screenAvail.x + screenGeom.x,screenAvail.y + screenGeom.y,screenAvail.width, screenAvail.height);
        if (screen.width > (kicker.cellSizeWidth *  Plasmoid.configuration.numberColumns) + Kirigami.Units.gridUnit){ return 0; }
        else { return screen.width - Kirigami.Units.gridUnit * 2 ; }
    }
    function resizeHeight()
    {
        var screenAvail = kicker.availableScreenRect;
        var screenGeom = kicker.screenGeometry;
        var screen = Qt.rect(screenAvail.x + screenGeom.x,screenAvail.y + screenGeom.y,screenAvail.width, screenAvail.height);
        if (screen.height > (kicker.cellSizeHeight *  Plasmoid.configuration.numberRows) + rootItem.visible_items + Kirigami.Units.gridUnit * 1.5) {return 0;}
        else { return screen.height - Kirigami.Units.gridUnit * 2;}
    }
    function updateLayouts()
    {
        rootItem.searchvisible = Plasmoid.configuration.showSearch;
        rootItem.visible_items = (Plasmoid.configuration.showInfoUser ? headingSvg.height : 0) + (rootItem.searchvisible == true ? rowSearchField.height : 0) + ( kicker.view_any_controls == true ? footer.height : 0)+ Kirigami.Units.gridUnit
        rootItem.cuadricula_hg = (kicker.cellSizeHeight *  Plasmoid.configuration.numberRows);
        rootItem.calc_width = (kicker.cellSizeWidth *  Plasmoid.configuration.numberColumns) + Kirigami.Units.gridUnit;
        rootItem.calc_height = rootItem.cuadricula_hg  + rootItem.visible_items;
        rootItem.userShape = calculateUserShape(Plasmoid.configuration.userShape);
        kicker.keyIn="Layout updated";
    }
    function calculateUserShape(shape)
    {
        switch (shape) {
        case 0: return (kicker.sizeImage * 0.85) / 2;
        case 1: return 8;
        case 2: return 0;
        default:return (kicker.sizeImage * 0.85) / 2;}
    }
    function setModels()
    {
        globalFavoritesGrid.model = globalFavorites
        allAppsGrid.model = rootModel.modelForRow(0);
    }

    onActiveFocusChanged:
    {
        if (!activeFocus && kicker.hideOnWindowDeactivate === false)
        {
            if (head_.item && head_.item.pinButton)
            {
                if (!head_.item.pinButton.checked)
                {
                    turnclose();
                }
            }
        }
    }

    Component.onCompleted:
    {
        rootModel.refreshed.connect(setModels)
        rootModel.refresh();
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(0,0);}
        else {mainColumn.tryActivate(0,0); }
    }
}
