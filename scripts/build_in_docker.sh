#!/bin/bash
#
# Copyright © 2016-2017 Oleksii Aliakin. All rights reserved.
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

if [ ! -z "$1" ]; then
    SRC_DIR=$(cd "$1" && pwd)
fi

APP_DIR_NAME=${APP_DIR_NAME:?}
APP_NAME=${APP_NAME:?}
: ${PROJECT_NAME:="___"}

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
ENTRY_POINT="/tmp/dock_${PROJECT_NAME}_entry_point.sh"

: ${SRC_DIR:=$(cd $SCRIPT_DIR/../ && pwd)}
: ${INSTALL_DIR:="/tmp/docker/$PROJECT_NAME"}
: ${BUILD_VARIANT:="release"}
: ${QBS_VERSION:="qbs:latest"}

INSTALL_DIR=${INSTALL_DIR}

echo "SRC_DIR: ${SRC_DIR}"
echo "INSTALL_DIR: ${INSTALL_DIR}"
echo "BUILD_VARIANT: ${BUILD_VARIANT}"
echo "QBS_VERSION: ${QBS_VERSION}"

mkdir -p ${INSTALL_DIR}

docker run --rm -ti                  \
    -v "$SRC_DIR":"$SRC_DIR":ro      \
    -v "$SCRIPT_DIR":/scripts:ro     \
    -v "$INSTALL_DIR":"$INSTALL_DIR" \
    -e HOST_USER_ID="$(id -u)"       \
    -e HOST_USER_GROUP_ID="$(id -g)" \
    -e HOST_USER_NAME="$USER"        \
    approximator/$QBS_VERSION        \
    sh -c "cd ${SRC_DIR} && /scripts/build.sh ${SRC_DIR} ${INSTALL_DIR}/install ${APP_DIR_NAME} ${APP_NAME} ${BUILD_VARIANT}"

res=$?

if [ $res -ne 0 ]; then
    echo "Failed"
    exit 1
else
    echo "Build finished!"
    echo "Installed in: ${INSTALL_DIR}"
    exit 0
fi
