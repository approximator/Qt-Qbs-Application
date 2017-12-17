#!/bin/bash

THIS_DIR=$(cd $(dirname $0) && pwd)

export APP_DIR_NAME=SimpleQtQmlApp
export APP_NAME=qtQmlsimple
export SRC_DIR=$(cd "$THIS_DIR/../../" && pwd)
export INSTALL_DIR=/tmp/Qt-Qbs-Application/examples
export SCRIPTS_DIR="$SRC_DIR/scripts"
export DEPLOYMENT_INFO_FILE="$THIS_DIR/deployment_info"

"$SCRIPTS_DIR/build_in_docker.sh"
