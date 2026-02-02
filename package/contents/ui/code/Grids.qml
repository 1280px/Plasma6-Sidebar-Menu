
import org.kde.plasma.components 3.0 as PC3
// import org.kde.plasma.private.kicker 0.1 as Kicker
// import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0
import QtQuick.Controls 2.15
// import org.kde.ksvg 1.0 as KSvg
import Qt5Compat.GraphicalEffects
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQml 2.15
import org.kde.kirigami 2.0  as Kirigami
import org.kde.plasma.plasmoid 2.0

FocusScope
{
    id: gridComponent
    height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items

    // Favourite apps
    ItemGridView
    {
        id: globalFavoritesGrid
        visible: (Plasmoid.configuration.showFavoritesFirst || kicker.showFavorites ) && !kicker.searching && kicker.showFavorites
        dragEnabled: true
        dropEnabled: true
        width: rootItem.width
        height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
        focus: true
        cellWidth:   kicker.cellSizeWidth
        cellHeight:  kicker.cellSizeHeight
        iconSize:    kicker.iconSize
    }
    Item
    {
        id: mainGrids
        visible: (
            !Plasmoid.configuration.showFavoritesFirst && !kicker.showFavorites
        ) || kicker.searching || !kicker.showFavorites // TODO
        width: rootItem.width

        Item
        {
            id: mainColumn
            width: rootItem.width
            height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
            property Item visibleGrid: allAppsGrid

            // All apps
            ItemGridView
            {
                id: allAppsGrid
                width: rootItem.width
                height: resizeHeight() == 0 ? rootItem.cuadricula_hg : resizeHeight() - rootItem.visible_items
                cellWidth:   kicker.cellSizeWidth
                cellHeight:  kicker.cellSizeHeight
                iconSize:    kicker.iconSize
                enabled: (opacity == 1) ? 1 : 0
                z:  enabled ? 5 : -1
                dropEnabled: false
                dragEnabled: false
                opacity: kicker.searching ? 0 : 1
                onOpacityChanged: {if (opacity == 1) { mainColumn.visibleGrid = allAppsGrid;}}
            }

            // Apps search
            ItemMultiGridView
            {
                id: runnerGrid
                width: rootItem.width
                height: rootItem.resizeHeight() == 0 ? rootItem.cuadricula_hg  : rootItem.resizeHeight() - rootItem.visible_items
                cellWidth:   kicker.cellSizeWidth
                cellHeight:  kicker.cellSizeHeight
                enabled: (opacity == 1.0) ? 1 : 0
                z:  enabled ? 5 : -1
                model: runnerModel
                grabFocus: true
                opacity: kicker.searching ? 1.0 : 0.0
                onOpacityChanged: {if (opacity == 1.0) { mainColumn.visibleGrid = runnerGrid;}}
            }

            // Positioning functions
            function tryActivate(row, col)
            {
                if (visibleGrid)
                {
                    visibleGrid.tryActivate(row, col);
                    // kicker.count = visibleGrid.count;
                }
            }
        }
    }
    
    // To be used by GridLoader
    function gridtryActivate(row, col)
    {
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(row,col);kicker.count = globalFavorites.count; rootItem.updateDimensions(); }
        else {mainColumn.tryActivate(row,col); kicker.count = mainColumn.visibleGrid.count; rootItem.updateDimensions(); }
    }
    function reset()
    {
        // mainColumn.tryActivate(0,0)
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(0,0);kicker.count = globalFavorites.count; rootItem.updateDimensions(); }
        else {mainColumn.tryActivate(0,0); kicker.count = mainColumn.visibleGrid.count; rootItem.updateDimensions(); }
    }
    function run()
    {
        runnerGrid.tryActivate(0,0)
    }
    function cargar()
    {
        if (kicker.showFavorites) {globalFavoritesGrid.tryActivate(0,0); kicker.count = globalFavorites.count;}
        else {mainColumn.tryActivate(0,0);  }
    }
    function setModels()
    {
        globalFavoritesGrid.model = globalFavorites
        allAppsGrid.model = rootModel.modelForRow(0);
    }

    Component.onCompleted:
    {
        rootModel.refreshed.connect(setModels)
        rootModel.refresh();
    }
}
