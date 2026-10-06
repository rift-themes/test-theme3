import QtQuick

Row {
    id: root

    property var hints: []

    spacing: 22

    Style { id: ui }

    Repeater {
        model: root.hints

        Row {
            required property var modelData
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(26, keyLabel.implicitWidth + 14)
                height: 26
                radius: 13
                color: "transparent"
                border.color: ui.muted
                border.width: 1.5

                Text {
                    id: keyLabel
                    anchors.centerIn: parent
                    text: modelData[0]
                    font.family: ui.body
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: ui.text
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData[1]
                font.family: ui.body
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: 1
                color: ui.muted
            }
        }
    }
}
