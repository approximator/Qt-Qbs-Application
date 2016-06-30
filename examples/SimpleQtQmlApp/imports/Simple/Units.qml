import QtQuick 2.0

pragma Singleton

QtObject {
    id: utils

    property real pixelDensity: 4.46
    property real multiplier: 1.4

    property color background: "white";
    property color buttonText: "white";
    property color text: "#1E1E1E";
    property color windowText: "#CCCCCC";
    property color hightlight: "#92DC5C";
    property color alternateBase: "#E6DED3"
    property color alternateLight: "#FAFAFA";

    function dp(number) {
        return Math.round(number*((pixelDensity*25.4)/160)*multiplier);
    }
}
