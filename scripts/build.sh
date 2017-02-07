#!/bin/bash
#
# Copyright © 2016 Oleksii Aliakin. All rights reserved.
# Author: Oleksii Aliakin (alex@nls.la).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# != 5 ]; then
   echo "Error! Please provide 5 parameters"
   echo "SRC_DIR, INSTALL_DIR, APP_DIR_NAME, APP_NAME, BUILD_VARIANT"
   exit 1
fi

ROOT_DIR=$(cd $(dirname $0) && pwd)
DEPLOY_SCRIPT=${ROOT_DIR}/deployqt.py
SRC_DIR=$1
INSTALL_DIR=$2
APP_DIR_NAME=$3
APP_NAME=$4
BUILD_VARIANT=$5     # release or debug

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
    --build-directory /tmp/build         \
    $BUILD_VARIANT                       \
    qbs.installRoot:$INSTALL_DIR         \
    profile:qt


run_and_check python -u ${DEPLOY_SCRIPT}                                       \
          --app-file      $INSTALL_DIR/$APP_DIR_NAME/$APP_NAME                 \
          --install-dir   $INSTALL_DIR/$APP_DIR_NAME                           \
          --data-dir      $INSTALL_DIR/$APP_DIR_NAME/data                      \
          --libraries-dir $INSTALL_DIR/$APP_DIR_NAME/data/lib                  \
          --qmake         $(which qmake)                                       \
          --debug-build   $BUILD_VARIANT                                       \
          --libs          Qt5Core Qt5Widgets Qt5Gui Qt5Qml Qt5Quick Qt5Network \
                          Qt5DBus Qt5Svg Qt5XcbQpa icudata icui18n icuuc pcre  \
                          Qt53DCore Qt53DRender Qt53DInput Qt53DLogic          \
                          Qt53DExtras Qt5Gamepad Qt5Concurrent Qt53DQuick      \
          --qt-plugins    iconengines imageformats platforms sceneparsers      \
                          platforminputcontexts xcbglintegrations              \
          --qml           Qt QtQuick QtQuick.2 QtGraphicalEffects Qt3D
