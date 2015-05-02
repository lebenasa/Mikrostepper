import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Menu {
    Menu {
        title: "Go to..."
        MenuItem {
            text: bookmarksettings.get(0).text
            enabled: bookmarksettings.get(0).enabled
            onTriggered: gotoBookmark(0)
        }
        MenuItem {
            text: bookmarksettings.get(1).text
            enabled: bookmarksettings.get(1).enabled
            onTriggered: gotoBookmark(1)
        }
        MenuItem {
            text: bookmarksettings.get(2).text
            enabled: bookmarksettings.get(2).enabled
            onTriggered: gotoBookmark(2)
        }
        MenuItem {
            text: bookmarksettings.get(3).text
            enabled: bookmarksettings.get(3).enabled
            onTriggered: gotoBookmark(3)
        }
        MenuItem {
            text: bookmarksettings.get(4).text
            enabled: bookmarksettings.get(4).enabled
            onTriggered: gotoBookmark(4)
        }
        MenuItem {
            text: bookmarksettings.get(5).text
            enabled: bookmarksettings.get(5).enabled
            onTriggered: gotoBookmark(5)
        }
        MenuItem {
            text: bookmarksettings.get(6).text
            enabled: bookmarksettings.get(6).enabled
            onTriggered: gotoBookmark(6)
        }
        MenuItem {
            text: bookmarksettings.get(7).text
            enabled: bookmarksettings.get(7).enabled
            onTriggered: gotoBookmark(7)
        }
        MenuItem {
            text: bookmarksettings.get(8).text
            enabled: bookmarksettings.get(8).enabled
            onTriggered: gotoBookmark(8)
        }
        MenuItem {
            text: bookmarksettings.get(9).text
            enabled: bookmarksettings.get(9).enabled
            onTriggered: gotoBookmark(9)
        }
    }
    Menu {
        title: "Bookmark"
        MenuItem {
            text: "Slot 1"
            onTriggered: bookmark(0)
        }
        MenuItem {
            text: "Slot 2"
            onTriggered: bookmark(1)
        }
        MenuItem {
            text: "Slot 3"
            onTriggered: bookmark(2)
        }
        MenuItem {
            text: "Slot 4"
            onTriggered: bookmark(3)
        }
        MenuItem {
            text: "Slot 5"
            onTriggered: bookmark(4)
        }
        MenuItem {
            text: "Slot 6"
            onTriggered: bookmark(5)
        }
        MenuItem {
            text: "Slot 7"
            onTriggered: bookmark(6)
        }
        MenuItem {
            text: "Slot 8"
            onTriggered: bookmark(7)
        }
        MenuItem {
            text: "Slot 9"
            onTriggered: bookmark(8)
        }
        MenuItem {
            text: "Slot 10"
            onTriggered: bookmark(9)
        }
    }

    function bookmark(index) {
        var xy = navigator.xy
        bookmarksettings.setProperty(index, "x", xy.x)
        bookmarksettings.setProperty(index, "y", xy.y)
        bookmarksettings.setProperty(index, "enabled", true)
        bookmarksettings.setProperty(index, "text", getText(index))
        saveBookmark(index)
    }

    function gotoBookmark(index) {
        var x = bookmarksettings.get(index).x
        var y = bookmarksettings.get(index).y
        navigator.moveXY(x, y)
    }

    function checkEnabled(index) {
        return bookmarksettings.get(index).enabled
    }

    function getText(index) {
        var x = bookmarksettings.get(index).x
        var y = bookmarksettings.get(index).y
        var msg = "Slot %1 : %2, %3"
        return msg.arg(index+1).arg(x).arg(y)
    }

    function loadBookmark(index) {
        var xy = appsettings.readPoint(bookmarksettings.get(index).name, Qt.point(0, 0))
        if (xy.x !== 0 && xy.y !== 0) {
            bookmarksettings.setProperty(index, "x", xy.x)
            bookmarksettings.setProperty(index, "y", xy.y)
            bookmarksettings.setProperty(index, "enabled", true)
            bookmarksettings.setProperty(index, "text", getText(index))
        }
    }

    function saveBookmark(index) {
        if (checkEnabled(index)) {
            var x = bookmarksettings.get(index).x
            var y = bookmarksettings.get(index).y
            appsettings.saveSettings(bookmarksettings.get(index).name, Qt.point(x, y))
        }
    }

    ListModel {
        id: bookmarksettings
        ListElement {
            name: "Bookmark1"
            text: "Slot 1"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark2"
            text: "Slot 2"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark3"
            text: "Slot 3"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark4"
            text: "Slot 4"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark5"
            text: "Slot 5"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark6"
            text: "Slot 6"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark7"
            text: "Slot 7"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark8"
            text: "Slot 8"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark9"
            text: "Slot 9"
            x: 0; y: 0
            enabled: false
        }
        ListElement {
            name: "Bookmark10"
            text: "Slot 10"
            x: 0; y: 0
            enabled: false
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < 10; ++i)
            loadBookmark(i)
    }
}

