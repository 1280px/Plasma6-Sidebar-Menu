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
    id: configHeader
    property alias cfg_showHeader: showHeader.checked
    property alias cfg_userShape: userShape.currentIndex
    property alias cfg_transparencyHeader: transparencyHeader.value

    Kirigami.FormLayout {
        CheckBox {
            id: showHeader
            Kirigami.FormData.label: i18n("Show header")
        }

        ComboBox {
            id: userShape
            Kirigami.FormData.label: i18n("User avatar shape:")
            model: [i18n("Circle"), i18n("Rounded square"), i18n("Square")]
        }

        SpinBox {
            id: transparencyHeader
            from: 0
            to: 100
            Kirigami.FormData.label: i18n("Background opacity, %:")
        }
    }
}
