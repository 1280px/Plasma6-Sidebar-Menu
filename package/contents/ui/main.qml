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

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

PlasmoidItem {
    id: kicker

    anchors.fill: parent
    signal reset

    property bool isDash: Plasmoid.pluginName === "org.kde.plasma.kickerdash"
    switchWidth: isDash || !fullRepresentationItem ? 0 : fullRepresentationItem.Layout.minimumWidth
    switchHeight: isDash || !fullRepresentationItem ? 0 : fullRepresentationItem.Layout.minimumHeight
    compactRepresentation: isDash ? null : compactRepresentation
    preferredRepresentation: isDash ?fullRepresentation : null
    fullRepresentation: isDash ? compactRepresentation : menuRepresentation

    // Configuration properties
    property bool showFavorites : Plasmoid.configuration.showFavoritesFirst
    property Item dragSource: null
    property bool searching: false

    // Keyboard
    property int currentColumn : 0
    property int currentRow : 0
    property int currentIndex: 0
    property int count: 0
    property string keyIn: ""

    // Commands
    readonly property string homeCMD: Plasmoid.configuration.homeSettings
    readonly property string downloadsCMD: Plasmoid.configuration.downloadsSettings
    readonly property string desktopCMD: Plasmoid.configuration.desktopSettings
    readonly property string systemPreferencesCMD: Plasmoid.configuration.systemPreferencesSettings
    readonly property string aboutThisComputerCMD: Plasmoid.configuration.aboutThisComputerSettings
    readonly property string forceQuitCMD: Plasmoid.configuration.forceQuitSettings

    // Images' & icons' properties
    property int sizeImage: Kirigami.Units.iconSizes.large * 2.5

    property int cellSizeHeight: (
        iconSize + Kirigami.Units.gridUnit * 2
        + (
            2 * Math.max(
                highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                highlightItemSvg.margins.left + highlightItemSvg.margins.right
            )
        )
    )
    property int cellSizeWidth: (
        cellSizeHeight + Kirigami.Units.gridUnit
    )

    property int iconSize: {
        switch (Plasmoid.configuration.appsIconSize) {
        case 0:
            return Kirigami.Units.iconSizes.smallMedium;
        case 1:
            return Kirigami.Units.iconSizes.medium;
        case 2:
            return Kirigami.Units.iconSizes.large;
        case 3:
            return Kirigami.Units.iconSizes.huge;
        default:
            return 64;
        }
    }

    Plasmoid.icon: (
        Plasmoid.configuration.useCustomButtonImage
        ? Plasmoid.configuration.customButtonImage
        : Plasmoid.configuration.icon
    )

    // Models
    property QtObject globalFavorites: rootModel.favoritesModel
    property QtObject systemFavorites: rootModel.systemFavoritesModel

    Kicker.RootModel {
        id: rootModel
        autoPopulate: false
        flat: true
        sorted: true
        showSeparators: false
        appletInterface: kicker
        showAllApps: true
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: true

        onShowRecentAppsChanged: {
            Plasmoid.configuration.showRecentApps = showRecentApps;
        }
        onShowRecentDocsChanged: {
            Plasmoid.configuration.showRecentDocs = showRecentDocs;
        }
        onRecentOrderingChanged: {
            Plasmoid.configuration.recentOrdering = recentOrdering;
        }
        Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + Plasmoid.id)
            if (!Plasmoid.configuration.favoritesPortedToKAstats)
            {
                if (favoritesModel.count < 1)
                {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favoriteApps);
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
        }
    }

    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: kicker
        favoritesModel: globalFavorites
        runners: {
            const results = [
                "krunner_services",
                "krunner_systemsettings",
                "krunner_sessions",
                "krunner_powerdevil",
                "calculator",
                "unitconverter"
            ];

            if (Plasmoid.configuration.useExtraRunners) {
                results.push(Plasmoid.configuration.extraRunners);
            }

            return results;
        }
    }

    Kicker.DragHelper {
        id: dragHelper
        dragIconSize: Kirigami.Units.iconSizes.medium
    }
    Kicker.ProcessRunner {
        id: processRunner
    }
    Kicker.WindowSystem {
        id: windowSystem
    }

    // Model Connections
    Connections {
        target: globalFavorites
        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteApps = target.favorites;
        }
    }
    Connections {
        target: systemFavorites
        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteSystemActions = target.favorites;
        }
    }
    Connections {
        target: Plasmoid.configuration
        function onFavoriteAppsChanged () {
            globalFavorites.favorites = Plasmoid.configuration.favoriteApps;
        }
    }
    Connections {
        target: kicker
        function onExpandedChanged(expanded) {
            if (expanded) {
                windowSystem.monitorWindowVisibility(Plasmoid.fullRepresentationItem);
                justOpenedTimer.start();
            } else {
                kicker.reset();
            }
        }
    }

    // Components UI
    PlasmaExtras.Menu {
        id: contextMenu
        PlasmaExtras.MenuItem {
            action: Plasmoid.internalAction("configure")
        }

    }

    PlasmaExtras.Highlight {
        id: delegateHighlight
        visible: false
        z: -1 // Otherwise it shows on top of the icon/label and tints them slightly
    }

    Kirigami.Heading {
        id: dummyHeading
        visible: false
        width: 0
        level: 5
    }

    // SVG
    KSvg.FrameSvgItem {
        id: panelSvg
        visible: false
        imagePath: "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: scrollbarSvg
        visible: false
        imagePath: "widgets/scrollbar"
    }
    KSvg.FrameSvgItem {
        id: highlightItemSvg
        visible: false
        imagePath: "widgets/viewitem"
        prefix: "hover"
    }
    KSvg.FrameSvgItem {
        id: listItemSvg
        visible: false
        imagePath: "widgets/listitem"
        prefix: "normal"
    }
    KSvg.FrameSvgItem {
        id: backgroundSvg
        visible: false
        imagePath: "dialogs/background"
    }

    PC3.Label {
        id: toolTipDelegate
        property Item toolTip
        width: contentWidth
        height: undefined
        text: toolTip ? toolTip.text : ""
        textFormat: Text.PlainText
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Edit Applications")
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    // Components
    Timer {
        id: justOpenedTimer
        repeat: false
        interval: 600
    }
    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }
    Component {
        id: menuRepresentation
        MenuRepresentation {}
    }

    Component.onCompleted: {
        if (Plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            Plasmoid.activationTogglesExpanded = !kicker.isDash
        }

        windowSystem.focusIn.connect(enableHideOnWindowDeactivate);
        kicker.hideOnWindowDeactivate = true;
        kicker.FramelessWindowHint=true;
        updateSvgMetrics();
        PlasmaCore.Theme.themeChanged.connect(updateSvgMetrics);
        rootModel.refreshed.connect(reset);
        dragHelper.dropped.connect(resetDragSource);
    }

    // Functions
    function updateSvgMetrics() {}
    function resetDragSource() { dragSource = null; }
    function toggle() { kicker.expanded = !kicker.expanded; }
    function action_menuedit() { processRunner.runMenuEditor(); }
    function enableHideOnWindowDeactivate() { kicker.hideOnWindowDeactivate = true; }
}
