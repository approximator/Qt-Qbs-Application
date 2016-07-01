#!/bin/bash

if [ ! -z "$1" ]; then
    SRC_DIR=$(cd $1 && pwd)
fi

if [ ! -z "$2" ]; then
    QBS_VERSION=$2
fi

: ${PROJECT_NAME:="___"}

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
SCRIPT_NAME="$(basename \"$(test -L \"$0\" && readlink \"$0\" || echo \"$0\")\")"
ENTRY_POINT="/tmp/dock_${PROJECT_NAME}_entry_point.sh"

: ${SRC_DIR:=$(cd $SCRIPT_DIR/../ && pwd)}
: ${INSTALL_DIR:="/tmp/docker/$PROJECT_NAME"}
: ${BUILD_VARIANT:="release"}
: ${QBS_VERSION:="qbs:1.5.1.Qt5.7.0"}

INSTALL_DIR=${INSTALL_DIR}

echo "SRC_DIR: ${SRC_DIR}"
echo "INSTALL_DIR: ${INSTALL_DIR}"
echo "BUILD_VARIANT: ${BUILD_VARIANT}"
echo "QBS_VERSION: ${QBS_VERSION}"

mkdir -p ${INSTALL_DIR}

cat > ${ENTRY_POINT} << EOF
#!/bin/bash

groupadd -g $(getent group $USER | cut -d: -f3) $USER
useradd -g $USER -G sudo -N -u $UID $USER
mkdir /builduser
chown -R $USER:$USER ${INSTALL_DIR}
chown -R $USER:$USER /builduser
/bin/su $USER -c "export HOME=/builduser && cd ${SRC_DIR} && /scripts/build.sh ${SRC_DIR} ${INSTALL_DIR}/install ${BUILD_VARIANT}"

EOF
chmod +x ${ENTRY_POINT}

VOLUMES="-v ${ENTRY_POINT}:${ENTRY_POINT}:ro -v ${SRC_DIR}:${SRC_DIR}:ro"
VOLUMES="${VOLUMES} -v ${SCRIPT_DIR}:/scripts:ro"
VOLUMES="${VOLUMES} -v ${INSTALL_DIR}:${INSTALL_DIR}"

docker run --rm --entrypoint=${ENTRY_POINT} ${VOLUMES} approximator/${QBS_VERSION}
res=$?

if [ $res -ne 0 ]; then
    echo "Failed"
    exit 1
else
    echo "Build finished!"
    echo "Installed in: ${INSTALL_DIR}"
    exit 0
fi
