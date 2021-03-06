// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import UM 1.2 as UM
import Cura 1.0 as Cura

UM.Dialog
{
    id: base
    title: catalog.i18nc("@title:window", "Save Project")

    minimumWidth: 500 * screenScaleFactor
    minimumHeight: 400 * screenScaleFactor
    width: minimumWidth
    height: minimumHeight

    property int spacerHeight: 10 * screenScaleFactor

    property bool dontShowAgain: true

    signal yes();

    function accept() {  // pressing enter will call this function
        close();
        yes();
    }

    onClosing:
    {
        UM.Preferences.setValue("cura/dialog_on_project_save", !dontShowAgainCheckbox.checked)
    }

    onVisibleChanged:
    {
        if(visible)
        {
            dontShowAgain = !UM.Preferences.getValue("cura/dialog_on_project_save")
        }
    }

    Item
    {
        anchors.fill: parent

        UM.SettingDefinitionsModel
        {
            id: definitionsModel
            containerId: base.visible ? Cura.MachineManager.activeDefinitionId: ""
            showAll: true
            exclude: ["command_line_settings"]
            showAncestors: true
            expanded: ["*"]
            visibilityHandler: UM.SettingPreferenceVisibilityHandler { }
        }
        UM.I18nCatalog
        {
            id: catalog
            name: "cura"
        }
        SystemPalette
        {
            id: palette
        }
        Label
        {
            id: mainHeading
            width: parent.width
            text: catalog.i18nc("@action:title", "Summary - Cura Project")
            font.pointSize: 18
            anchors.top: parent.top
        }
        ScrollView
        {
            id: scroll
            width: parent.width
            anchors
            {
                top: mainHeading.bottom
                topMargin: UM.Theme.getSize("default_margin").height
                bottom: controls.top
                bottomMargin: UM.Theme.getSize("default_margin").height
            }
            style: UM.Theme.styles.scrollview
            ColumnLayout
            {
                spacing: UM.Theme.getSize("default_margin").height
                Column
                {
                    Label
                    {
                        id: settingsHeading
                        text: catalog.i18nc("@action:label", "Printer settings")
                        font.bold: true
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Type")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: (Cura.MachineManager.activeMachine == null) ? "" : Cura.MachineManager.activeMachine.definition.name
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: Cura.MachineManager.activeMachineNetworkGroupName != "" ? catalog.i18nc("@action:label", "Printer Group") : catalog.i18nc("@action:label", "Name")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: Cura.MachineManager.activeMachineNetworkGroupName != "" ? Cura.MachineManager.activeMachineNetworkGroupName : Cura.MachineManager.activeMachineName
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                }
                Row
                {
                    visible: Cura.MachineManager.hasVariantBuildplates
                    width: parent.width
                    height: childrenRect.height
                    Label
                    {
                        text: catalog.i18nc("@action:label", "Build plate")
                        width: Math.floor(scroll.width / 3) | 0
                    }
                    Label
                    {
                        text: Cura.MachineManager.activeVariantBuildplateName
                        width: Math.floor(scroll.width / 3) | 0
                    }
                }
                Repeater
                {
                    width: parent.width
                    height: childrenRect.height
                    model: Cura.MachineManager.currentExtruderPositions
                    delegate: Column
                    {
                        height: childrenRect.height
                        width: parent.width
                         Label
                        {
                            text: {
                                var extruder = Number(modelData)
                                var extruder_id = ""
                                if(!isNaN(extruder))
                                {
                                    extruder_id = extruder + 1 // The extruder counter start from One and not Zero
                                }
                                else
                                {
                                    extruder_id = modelData
                                }

                                return catalog.i18nc("@action:label", "Extruder %1").arg(extruder_id)
                            }
                            font.bold: true
                        }
                        Row
                        {
                            width: parent.width
                            height: childrenRect.height
                            Label
                            {
                                text: catalog.i18nc("@action:label", "%1 & material").arg(Cura.MachineManager.activeDefinitionVariantsName)
                                width: Math.floor(scroll.width / 3) | 0
                            }
                            Label
                            {
                                text: Cura.MachineManager.activeVariantNames[modelData] + ", " + Cura.MachineManager.getExtruder(modelData).material.name
                                width: Math.floor(scroll.width / 3) | 0
                            }
                        }
                    }
                }
                Column
                {
                    width: parent.width
                    height: childrenRect.height
                    Label
                    {
                        text: catalog.i18nc("@action:label", "Profile settings")
                        font.bold: true
                    }
                    Row
                    {
                        width: parent.width
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Not in profile")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: catalog.i18ncp("@action:label", "%1 override", "%1 overrides", Cura.MachineManager.numUserSettings).arg(Cura.MachineManager.numUserSettings)
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        visible: Cura.MachineManager.numUserSettings
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Name")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: Cura.MachineManager.activeQualityOrQualityChangesName
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                }
            }
        }
        Item
        {
            id: controls
            width: parent.width
            height: childrenRect.height
            anchors.bottom: parent.bottom
            CheckBox
            {
                id: dontShowAgainCheckbox
                anchors.left: parent.left
                text: catalog.i18nc("@action:label", "Don't show project summary on save again")
                checked: dontShowAgain
            }
            Button
            {
                id: cancel_button
                anchors
                {
                    right: ok_button.left
                    rightMargin: UM.Theme.getSize("default_margin").width
                }
                text: catalog.i18nc("@action:button","Cancel");
                enabled: true
                onClicked: close()
            }
            Button
            {
                id: ok_button
                anchors.right: parent.right
                text: catalog.i18nc("@action:button","Save");
                enabled: true
                onClicked:
                {
                    close()
                    yes()
                }
            }
        }
    }
}
