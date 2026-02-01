/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.5 as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM


KCM.SimpleKCM {
    id: configAppearance
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberRows: numberRows.value

    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_userShape: userShape.currentIndex

    property alias cfg_transparencyHead: transparencyHead.value
    property alias cfg_transparencyFooter: transparencyFooter.value

    Kirigami.FormLayout
    {
        ComboBox
        {

            Kirigami.FormData.label: i18n("Avatar User Shape")
            id: userShape
            model: [
                i18n("Circle"),
                i18n("RoundCorner"),
                i18n("Square"),
            ]
        }

        ComboBox {
            id: appsIconSize
            Kirigami.FormData.label: i18n("App icons size:")
            Layout.fillWidth: true
            model: [i18n("Small"),i18n("Medium"),i18n("Large"), i18n("Huge")]
        }

        SpinBox{
            id: numberColumns
            from: 3
            to: 15
            Kirigami.FormData.label: i18n("App number of columns")

        }

        SpinBox{
            id: numberRows
            from: 1
            to: 15
            Kirigami.FormData.label: i18n("App number of rows")
        }


        SpinBox{
            id: transparencyHead
            from:1
            to: 100
            Kirigami.FormData.label: i18n("Porcent Heading Opacity")

        }

        SpinBox{
            id: transparencyFooter
            from:1
            to: 100
            Kirigami.FormData.label: i18n("Porcent Fotter Opacity")

        }


    }
}
