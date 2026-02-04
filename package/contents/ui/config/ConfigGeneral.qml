/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

import org.kde.draganddrop 2.0 as DragDrop
import org.kde.iconthemes as KIconThemes
import org.kde.kcmutils as KCM
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0

KCM.SimpleKCM {
    id: configGeneral
    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_showSearch: showSearch.currentIndex
    property alias cfg_showFavoritesFirst: showFavoritesFirst.checked

    property string defaultIcon: "go-first-symbolic-rtl"

    function getBackgroundColorContrast() {
        const hex = `${PlasmaCore.Theme.backgroundColor}`.substring(1);
        const r = parseInt(hex.substring(0, 2), 16);
        const g = parseInt(hex.substring(2, 4), 16);
        const b = parseInt(hex.substring(4, 6), 16);

        const luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        return luma > 128 ? "dark" : "light";
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Button {
            id: iconButton
            Kirigami.FormData.label: i18n("Icon:")
            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
            // Just to provide some visual feedback when dragging;
            // cannot have checked without checkable enabled
            checkable: true
            checked: dropArea.containsAcceptableDrag
            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            DragDrop.DropArea {
                id: dropArea
                property bool containsAcceptableDrag: false
                anchors.fill: parent
                onDragEnter: {
                    // Cannot use string operations (e.g. indexOf()) on "url" basic type.
                    var urlString = event.mimeData.url.toString();
                    // This list is also hardcoded in KIconDialog.
                    var extensions = [".png", ".xpm", ".svg", ".svgz"];

                    containsAcceptableDrag = (
                        (urlString.indexOf("file:///") === 0 && extensions.some(
                            function(extension) {
                                return urlString.indexOf(extension) === urlString.length - extension.length; // "endsWith"
                            }
                        ))
                    );
                    if (!containsAcceptableDrag) {
                        event.ignore();
                    }

                }
                onDragLeave: containsAcceptableDrag = false
                onDrop: {
                    if (containsAcceptableDrag) {
                        // Strip file:// prefix, we already verified in onDragEnter that we have only local URLs.
                        iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));
                    }
                    containsAcceptableDrag = false;
                }
            }

            KIconThemes.IconDialog {
                id: iconDialog
                function setCustomButtonImage(image) {
                    configGeneral.cfg_customButtonImage = image || defaultIcon;
                    configGeneral.cfg_useCustomButtonImage = true;
                }
                onIconNameChanged: setCustomButtonImage(iconName)
            }

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: (
                    (Plasmoid.formFactor === PlasmaCore.Types.Vertical)
                    || (
                        Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                            ? "widgets/panel-background"
                            : "widgets/background"
                    )
                )
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: (
                        configGeneral.cfg_useCustomButtonImage
                            ? configGeneral.cfg_customButtonImage
                            : defaultIcon
                    )
                }
            }

            Menu {
                id: iconMenu
                y: +parent.height // Appear below the button
                onClosed: iconButton.checked = false

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    onClicked: iconDialog.open()
                }

                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                    icon.name: "edit-clear"
                    onClicked: {
                        configGeneral.cfg_icon = defaultIcon;
                        configGeneral.cfg_useCustomButtonImage = false;
                    }
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        SpinBox {
            id: numberColumns
            from: 3
            to: 6
            Kirigami.FormData.label: i18n("Apps per column:")
        }

        ComboBox {
            id: appsIconSize
            Kirigami.FormData.label: i18n("Icons size:")
            Layout.fillWidth: true
            model: [i18n("Small"), i18n("Medium"), i18n("Large"), i18n("Huge")]
        }

        ComboBox {
            id: showSearch
            Kirigami.FormData.label: i18n("Search text input:")
            Layout.fillWidth: true
            model: [i18n("Shown below header"), i18n("Shown above footer"), i18n("Hidden (invisible)")]
        }

        CheckBox {
            id: showFavoritesFirst
            Kirigami.FormData.label: i18n("Open favorites first")
        }
    }
}
