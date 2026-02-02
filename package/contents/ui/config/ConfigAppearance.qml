/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

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
    id: configAppearance
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberRows: numberRows.value
    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_userShape: userShape.currentIndex
    property alias cfg_transparencyHead: transparencyHead.value
    property alias cfg_transparencyFooter: transparencyFooter.value

    Kirigami.FormLayout {
        ComboBox {
            id: userShape
            Kirigami.FormData.label: i18n("Avatar User Shape")
            model: [i18n("Circle"), i18n("RoundCorner"), i18n("Square")]
        }

        ComboBox {
            id: appsIconSize
            Kirigami.FormData.label: i18n("Icons size:")
            Layout.fillWidth: true
            model: [i18n("Small"), i18n("Medium"), i18n("Large"), i18n("Huge")]
        }

        SpinBox {
            id: numberColumns
            from: 3
            to: 15
            Kirigami.FormData.label: i18n("Number of columns:")
        }

        SpinBox {
            id: numberRows
            from: 1
            to: 15
            Kirigami.FormData.label: i18n("Number of rows:")
        }

        SpinBox {
            id: transparencyHead
            from: 1
            to: 100
            Kirigami.FormData.label: i18n("Header opacity, %:")
        }

        SpinBox {
            id: transparencyFooter
            from: 1
            to: 100
            Kirigami.FormData.label: i18n("Fotter opacity, %:")
        }
    }
}
