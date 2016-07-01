#!/bin/bash

if [ $# != 3 ]; then
   echo "Error! Please provide 3 parameters"
   echo "SRC_DIR, INSTALL_DIR, BUILD_VARIANT"
   exit 1
fi

ROOT_DIR=$(cd $(dirname $0) && pwd)
DEPLOY_SCRIPT=${ROOT_DIR}/deployqt.py
SRC_DIR=$1
INSTALL_DIR=$2
BUILD_VARIANT=$3     # release or debug

echo ""
echo "I am: $(id)"
echo ""
echo "SRC_DIR:          $SRC_DIR"
echo "INSTALL_DIR:      $INSTALL_DIR"
echo "BUILD_VARIANT:    $BUILD_VARIANT"
echo "qmake version:    $(qmake --version)"
# echo "qbs version:      $(qbs --version)"

function run_and_check {
    echo ""
    echo ""
    echo "  Executing: $@"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Error executing: $@" >&2
        exit 1
    fi
}

run_and_check qbs setup-toolchains --detect
run_and_check qbs setup-qt $(which qmake) qt
run_and_check qbs config profiles.qt.baseProfile gcc
run_and_check qbs config --list profiles
run_and_check qbs config defaultProfile qt

run_and_check qbs build                  \
    --file $SRC_DIR                      \
    --command-echo-mode command-line     \
    --clean-install-root                 \
    --build-directory /tmp/fgap_build    \
    $BUILD_VARIANT                       \
    qbs.installRoot:$INSTALL_DIR         \
    profile:qt


run_and_check python -u ${DEPLOY_SCRIPT}                                       \
          --app-file      $INSTALL_DIR/simpleQtQmlApp/qtQmlsimple              \
          --install-dir   $INSTALL_DIR/simpleQtQmlApp                          \
          --data-dir      $INSTALL_DIR/simpleQtQmlApp/data                     \
          --libraries-dir $INSTALL_DIR/simpleQtQmlApp/data/lib                 \
          --qmake         $(which qmake)                                       \
          --debug-build   $BUILD_VARIANT                                       \
          --libs          Qt5Core Qt5Widgets Qt5Gui Qt5Qml Qt5Quick Qt5Network \
                          Qt5DBus Qt5Svg Qt5XcbQpa icudata icui18n icuuc pcre  \
          --qt-plugins    iconengines imageformats platforms                   \
                          platforminputcontexts xcbglintegrations              \
          --qml           Qt QtQuick QtQuick.2 QtGraphicalEffects
