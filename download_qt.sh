#!/bin/bash

QT_BASE_URL=${QT_BASE_URL-"http://download.qt.io/online/qtsdkrepository/mac_x64/desktop/qt5_592/"}
QT_VERSION_SHORT=${QT_VERSION_SHORT-"5.9.2"}
QT_VERSION=${QT_VERSION-"5.9.2-0-201710050729"}
QT_PACKAGE_PREFIX=${QT_PACKAGE_PREFIX-"qt.592."}
QT_PACKAGE_SUFFIX=${QT_PACKAGE_SUFFIX-"clang_64"}
QT_PREBUILT_SUFFIX=${QT_PREBUILT_SUFFIX-"-MacOS-OSX_10_10-Clang-MacOS-OSX_10_10-X86_64"}

COLOR_STATUS=$'\033[1m\033[32m'
COLOR_RESET=$'\033[0m'

function install_module() {
  echo "${COLOR_STATUS}Downloading $2${COLOR_RESET}"
  remote_sha1=$(curl -L "$2.sha1")
  curl -L -C - -o $1 $2
  local_sha1=$(shasum $1 | cut -d " " -f 1)
  if [[ "$remote_sha1" != "$local_sha1" ]]; then
    echo "$1: sha1 mismatch - local: $local_sha1; remote: $remote_sha1"
    exit 1
  fi
  7z x -y -oqt/ $1
}
function install_module_main() {
  url_base="$QT_BASE_URL$QT_PACKAGE_PREFIX$QT_PACKAGE_SUFFIX/$QT_VERSION$1$QT_PREBUILT_SUFFIX"
  install_module "qt_tmp/$1.7z" "$url_base.7z"
}
function install_module_extra() {
  url_base="$QT_BASE_URL$QT_PACKAGE_PREFIX$1.$QT_PACKAGE_SUFFIX/$QT_VERSION$2$QT_PREBUILT_SUFFIX"
  install_module "qt_tmp/$2.7z" "$url_base.7z"
}

mkdir -p qt
mkdir -p qt_tmp

install_module_main qtbase
install_module_main qtdeclarative
install_module_main qtgraphicaleffects
install_module_main qtsvg
install_module_main qtquickcontrols
install_module_main qtquickcontrols2
install_module_main qtwebchannel
install_module_main qttools
install_module_main qtlocation
install_module_extra qtwebengine qtwebengine

echo "${COLOR_STATUS}Patching$2${COLOR_RESET}"
cd qt/$QT_VERSION_SHORT/clang_64/
../../../patch_qt.sh

curl -L -C - -o sparkle.tar.xz https://github.com/sparkle-project/Sparkle/releases/download/1.26.0/Sparkle-1.26.0.tar.xz
tar -xf ./sparkle.tar.xz
mv Sparkle.framework lib/
