/*
    SPDX-FileCopyrightText: 2013-2014 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: root

    readonly property bool vertical: (
        Plasmoid.formFactor === PlasmaCore.Types.Vertical
    )
    readonly property bool useCustomButtonImage: (
        Plasmoid.configuration.useCustomButtonImage && Plasmoid.configuration.customButtonImage.length !== 0
    )
    readonly property Component dashWindowComponent: (
        kicker.isDash
            ? Qt.createComponent(Qt.resolvedUrl("./DashboardRepresentation.qml"), root)
            : null
    )
    readonly property Kicker.DashboardWindow dashWindow: (
        dashWindowComponent && dashWindowComponent.status === Component.Ready
            ? dashWindowComponent.createObject(
                root, { "visualParent": root }
            )
            : null
    )

    onWidthChanged: updateSizeHints()
    onHeightChanged: updateSizeHints()

    function updateSizeHints() {
        if (useCustomButtonImage) {
            if (vertical) {
                const scaledHeight = Math.floor(parent.width * (buttonIcon.implicitHeight / buttonIcon.implicitWidth));
                root.Layout.minimumWidth = -1;
                root.Layout.minimumHeight = scaledHeight;
                root.Layout.maximumWidth = Kirigami.Units.iconSizes.huge;
                root.Layout.maximumHeight = scaledHeight;
            } else {
                const scaledWidth = Math.floor(parent.height * (buttonIcon.implicitWidth / buttonIcon.implicitHeight));
                root.Layout.minimumWidth = scaledWidth;
                root.Layout.minimumHeight = -1;
                root.Layout.maximumWidth = scaledWidth;
                root.Layout.maximumHeight = Kirigami.Units.iconSizes.huge;
            }
        } else {
            root.Layout.minimumWidth = -1;
            root.Layout.minimumHeight = -1;
            root.Layout.maximumWidth = Kirigami.Units.iconSizes.huge;
            root.Layout.maximumHeight = Kirigami.Units.iconSizes.huge;
        }
    }

    function getIcon() {
        const colorContrast = getBackgroundColorContrast();
        return `assets/logo-${colorContrast}.svg`;
    }

    function getBackgroundColorContrast() {
        const hex = `${PlasmaCore.Theme.backgroundColor}`.substring(1);
        const r = parseInt(hex.substring(0, 2), 16);
        const g = parseInt(hex.substring(2, 4), 16);
        const b = parseInt(hex.substring(4, 6), 16);

        const l = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        return l > 128 ? "dark" : "light";
    }

    Kirigami.Icon {
        id: buttonIcon
        readonly property double aspectRatio: (
            root.vertical
                ? implicitHeight / implicitWidth
                : implicitWidth / implicitHeight
        )
        source: (
            root.useCustomButtonImage 
                ? Plasmoid.configuration.customButtonImage
                : Plasmoid.configuration.icon
        )
        anchors.fill: parent
        active: mouseArea.containsMouse && !justOpenedTimer.running
        // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
        // to be an icon and round it to the nearest icon size again to avoid scaling artifacts.
        roundToIconSize: !root.useCustomButtonImage || aspectRatio === 1
        onSourceChanged: root.updateSizeHints()
    }

    MouseArea {
        id: mouseArea
        property bool wasExpanded: false
        anchors.fill: parent
        activeFocusOnTab: true
        hoverEnabled: (!root.dashWindow || !root.dashWindow.visible)

        Accessible.name: Plasmoid.title
        Accessible.description: toolTipSubText
        Accessible.role: Accessible.Button

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                Plasmoid.activated();
                break;
            }
        }
        onPressed: {
            if (!kicker.isDash) {
                wasExpanded = kicker.expanded;
            }
        }
        onClicked: {
            if (kicker.isDash) {
                root.dashWindow.toggle();
                justOpenedTimer.start();
            } else {
                kicker.expanded = !wasExpanded;
            }
        }
    }

    Connections {
        function onActivated() {
            root.dashWindow.toggle();
            justOpenedTimer.start();
        }

        target: Plasmoid
        enabled: kicker.isDash && root.dashWindow !== null
    }
}
