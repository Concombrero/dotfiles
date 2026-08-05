import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#fdf6e3"

    property color panelBase: "#fdf6e3"
    property color panelSurface: "#eee8d5"
    property color panelText: "#586e75"
    property color accentColor: "#268bd2"
    property color errorColor: "#dc322f"
    property int columnSpacing: Math.round(root.height * 0.04)
    property int rowSpacing: Math.round(root.width * 0.007)
    property int lockSize: Math.round(root.height * 0.025)
    property int fieldWidth: Math.round(root.width * 0.17)
    property int fieldHeight: Math.round(root.height * 0.04)
    property int fieldPadding: Math.round(root.height * 0.008)
    property int usernameFontSize: Math.round(root.height * 0.02)
    property int passwordFontSize: Math.round(root.height * 0.02)
    property int errorFontSize: Math.round(root.height * 0.018)
    property int errorHeight: Math.round(root.height * 0.03)
    property string fontFamily: "JetBrainsMono Nerd Font"

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "background-blur.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: root.panelBase
        opacity: backgroundImage.status === Image.Ready ? 0.35 : 1.0
    }

    property string currentUser: userModel.lastUser
    property int sessionIndex: {
        return sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Login failed"
            password.text = ""
            if (username.text === "")
                username.forceActiveFocus()
            else
                password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }

    Column {
        id: loginForm
        anchors.centerIn: parent
        spacing: root.columnSpacing
        width: parent.width

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.rowSpacing

            Text {
                text: "\uf007"
                color: root.panelText
                font.family: root.fontFamily
                font.pixelSize: root.lockSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: root.fieldWidth
                height: root.fieldHeight
                color: root.panelSurface
                border.color: root.accentColor
                border.width: 1
                clip: true

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.margins: root.fieldPadding
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: root.fontFamily
                    font.pixelSize: root.usernameFontSize
                    color: root.panelText
                    text: root.currentUser

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            password.forceActiveFocus()
                            event.accepted = true
                        }
                    }
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.rowSpacing

            Text {
                text: "\uf023"
                color: root.panelText
                font.family: root.fontFamily
                font.pixelSize: root.lockSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: root.fieldWidth
                height: root.fieldHeight
                color: root.panelSurface
                border.color: root.accentColor
                border.width: 1
                clip: true

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.margins: root.fieldPadding
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    font.family: root.fontFamily
                    font.pixelSize: root.passwordFontSize
                    font.letterSpacing: root.height * 0.004
                    passwordCharacter: "\u2022"
                    color: root.panelText
                    focus: true

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username.text, password.text, root.sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }
        }

    }

    Text {
        id: errorMessage
        anchors.top: loginForm.bottom
        anchors.topMargin: root.columnSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        text: ""
        height: root.errorHeight
        color: root.errorColor
        font.family: root.fontFamily
        font.pixelSize: root.errorFontSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: text.length > 0 ? 1 : 0
    }

    Component.onCompleted: {
        if (username.text === "")
            username.forceActiveFocus()
        else
            password.forceActiveFocus()
    }
}
