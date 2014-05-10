#!/bin/bash

set -e

: ${BUILD_NUMBER:?"Need non empty BUILD_NUMBER variable! If you are starting this script from cli you should use build-cli.sh"}
: ${GIT_BRANCH:?"Need non empty GIT_BRANCH variable"}
: ${JOB_NAME:?"Need non empty JOB_NAME variable"}

SCRIPT_DIR=$(dirname $0)

export WORKSPACE=${WORKSPACE:-$(readlink -f ${SCRIPT_DIR}/..)}
export NAME=${JOB_NAME}-${GIT_BRANCH}

export ROOT_ENV=$WORKSPACE/root_env
export INSTALL_DIR=/usr/lib/$NAME
export PID_DIR=/var/run/$NAME
export LOG_DIR=/var/log/$NAME

export PORT=12000
export MODE=prod
export VERSION=1.0

if [ `python2 -c "import jinja2"` ]; then
  echo "This scrips needs jinja2 for template rendering, aborting ..."
  exit 1
fi

stage() {
  echo "[*] compiling..."
  cd $WORKSPACE
  sbt clean compile stage
}

createRootEnvironment() {
  echo "[*] creating root environment..."
  cd $WORKSPACE
  if [ -d ${ROOT_ENV} ]; then
    rm -rf ${ROOT_ENV}
  elif [ -e ${ROOT_ENV} ]; then
    echo "Root Environment $ROOT_ENV exists, but is not a directory, aborting..."
    return 1
  fi
  mkdir ${ROOT_ENV}
}

copyBinariesToRootEnvironment(){
  echo "[*] copying binary files..."
  INSTALL_DIR_PATH=${ROOT_ENV}${INSTALL_DIR}
  mkdir -p $INSTALL_DIR_PATH
  cp -r $WORKSPACE/target/universal/stage $INSTALL_DIR_PATH
}

renderTemplate() {
  TEMPLATE_CONTENT=$(< $1)

  python2 -c "import jinja2; print jinja2.Template(\"\"\"$TEMPLATE_CONTENT\"\"\").render(\
    name=\"$NAME\", project=\"$JOB_NAME\", branch=\"$GIT_BRANCH\", mode=\"$MODE\", port=\"$PORT\", \
    install_dir=\"$INSTALL_DIR\", pid_dir=\"$PID_DIR\", log_dir=\"#LOG_DIR\")"

}

renderAllTemplates() {
  TEMPLATES=$(find $WORKSPACE/build/templates -type f)
  while read -r TEMPLATE; do
    TEMPLATE_PATH=${TEMPLATE#*/templates/}
    echo "[*] rendering template $TEMPLATE_PATH"
    mkdir -p $ROOT_ENV/`dirname $TEMPLATE_PATH`
    renderTemplate $TEMPLATE > $ROOT_ENV/$TEMPLATE_PATH
  done <<< $TEMPLATES
}

buildPackage() {
  echo "[*] creating package"

  DIRS=`ls -x $ROOT_ENV`
  INSTALL_SCRIPT_DIR=${WORKSPACE}/build/install_scripts
  
  cd $WORKSPACE

  fpm -m thomas@scm.io -s dir -t deb \
  -n ${NAME} \
  -v $VERSION \
  --iteration ${BUILD_NUMBER} \
  --before-install="${INSTALL_SCRIPT_DIR}/before-install.sh" \
  --after-remove="${INSTALL_SCRIPT_DIR}/after-remove.sh" \
  --template-scripts \
  --template-value name="${NAME}" \
  --template-value project="${JOB_NAME}" \
  --template-value branch="${GIT_BRANCH}" \
  --template-value mode="${MODE}" \
  --template-value install_dir="${INSTALL_DIR}" \
  --template-value pid_dir="${PID_DIR}" \
  --template-value log_dir="${LOG_DIR}" \
  -C ${ROOT_ENV} ${DIRS}
}

cleanUp() {
  echo "[*] cleaning up..."
  rm -rf $ROOT_ENV
}

stage
createRootEnvironment
copyBinariesToRootEnvironment
renderAllTemplates
buildPackage
cleanUp