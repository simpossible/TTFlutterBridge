#!/bin/sh
SDK_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
case $SDK_ROOT_DIR in  
     *\ * )
           echo "您的路径中包含空格，像'make install'是不被支持的."
           exit 1
          ;;
esac
###########################################################################
#
# 模拟器支持架构
SIMULATOR_ARCHS="i386 x86_64"
#
# 真机支持架构
IPHONEOS_ARCHS="armv7 arm64"
#
# 编译使用的SDK
SDK_NAME="iphoneos8.1"
#
# 编译产品路径，指定指定build目录（默认为脚本所在目录下的build）
BUILT_PRODUCTS_DIR="${SDK_ROOT_DIR}/build"
#
# 当前framework版本，一般使用字母递增来表示
FRAMEWORK_VERSION="A"
#                                                                         
###########################################################################
function show_version() {
        echo "version: 1.1"
        echo "updated date: 2015-04-20"
}
function show_usage() {
        echo "Usage(暂时不支持长选项):\n"
        echo "`printf %-16s "    $ $0"` argument\n" 
        echo "Description:"
        echo "`printf %-16s ` [-h|--help] 显示帮助信息"
        echo "`printf %-16s ` [-v|-V|--version] 显示版本"
        echo "`printf %-16s ` [-c|--configuration ... ] 指定编译配置"
        echo "`printf %-16s ` [-p|--project ... ] 指定编译工程"
        echo "`printf %-16s ` [-P|--frameworkproduct ... ] 指定生成framework产品名"
        echo "`printf %-16s ` [-t|--frameworktarget ... ] 指定需要编译framework的target名"
        echo "`printf %-16s ` [-r|--resourcetarget ... ] 指定资源编译target名"
        echo "`printf %-16s ` [-g|--path ... ] 打包完毕后需要拷贝到的路径"
}
# Call this when there is an error.  This does not return.

# 定义moudle
DEFINEMOUDLE="YES"

function die() {
  echo ""
  echo "FATAL: $*" >&2
  exit 1
}
# 工程名，用以指定需要编译的project
PROJECT_NAME=""
# target名，用以指定需要编译的target，默认与工程名一致
TARGET_NAME=""
# 产品名，用以指定需要编译的target，默认与target名一致
PRODUCT_NAME=""
# 配置，用以指定编译代码的配置
CONFIGURATION=""
# 资源名
RESOURCE_NAME=""
# 编译所有target标识
ALLTARGETS_FLAG=0
# 参数列表

COPYTO=""

while getopts ":hvVac:p:P:t:r:g:" OPTNAME
do
  case "$OPTNAME" in
    "h")
      show_usage && exit
      ;;
    "v")
      show_version && exit
      ;;
    "V")
      show_version && exit
      ;;
    "c")
      CONFIGURATION=$OPTARG
      ;;
    "p")
      PROJECT_NAME=$OPTARG
      ;;
    "P")
      PRODUCT_NAME=$OPTARG
      ;;
    "t")
      TARGET_NAME=$OPTARG
      ;;
    "r")
      RESOURCE_NAME=$OPTARG
      ;;
     "g")
      COPYTO=$OPTARG
      ;;
    "?")
      show_usage && exit
      ;;
    ":")
      echo "选项$OPTARG缺少输入参数"
      die
      ;;
    *)
    # Should not occur
      echo "处理选项过程发生未知错误"
      die
      ;;
  esac
done
XCODEPROJ_SEARCH_RESULT=`find . -name "*.xcodeproj" -d 1`
if [ -n "${XCODEPROJ_SEARCH_RESULT}" ]; then
  FILENAME="`basename ${XCODEPROJ_SEARCH_RESULT}`"
  XCODEPROJ_NAME="${FILENAME%.*}"
fi

test -n "${CONFIGURATION}"    || CONFIGURATION="Release"
test -n "${PROJECT_NAME}"     || PROJECT_NAME="${XCODEPROJ_NAME}"
test -n "${TARGET_NAME}"      || TARGET_NAME="${PROJECT_NAME}"
test -n "${PRODUCT_NAME}"     || PRODUCT_NAME="${TARGET_NAME}"

if [[ -z "${RESOURCE_NAME}" ]]; then
  TARGET_EXIST_STRING=`xcodebuild -project ./$PROJECT_NAME.xcodeproj -list | grep "${TARGET_NAME}Bundle"`
  test -z "${TARGET_EXIST_STRING}" || RESOURCE_NAME="${TARGET_NAME}Bundle"
fi

set -e
set +u
# 避免递归调用
if [[ $SF_MASTER_SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1
DEVELOPER=`xcode-select -print-path`
if [ ! -d "$DEVELOPER" ]; then
  echo "xcode路径没有被设置正确，$DEVELOPER不存在"
  echo "运行"
  echo "sudo xcode-select -switch <xcode path>"
  echo "来进行默认安装:"
  echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
  exit 1
fi
SDK_IPHONEOS="iphoneos"
SDK_IPHONESIMULATOR="iphonesimulator"
# The following conditionals come from
# https://github.com/kstenerud/iOS-Universal-Framework
if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
SF_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi
if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
then
SF_SDK_VERSION=${BASH_REMATCH[1]}
else
echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
exit 1
fi
if [[ "$SF_SDK_PLATFORM" = "iphoneos" ]]
then
SF_OTHER_PLATFORM=iphonesimulator
else
SF_OTHER_PLATFORM=iphoneos
fi
function buildFramework() {
  
  xcodebuild -project Pods/Pods.xcodeproj -target "Pods-${TARGET_NAME}" OTHER_CFLAGS="-fembed-bitcode" -sdk $SDK_IPHONEOS -configuration $CONFIGURATION ARCHS="${IPHONEOS_ARCHS}"  build
   xcodebuild -project Pods/Pods.xcodeproj -target "Pods-${TARGET_NAME}" OTHER_CFLAGS="-fembed-bitcode" -sdk $SDK_IPHONESIMULATOR -configuration $CONFIGURATION ARCHS="${SIMULATOR_ARCHS}" build  

  xcodebuild -project ./$PROJECT_NAME.xcodeproj -target $TARGET_NAME OTHER_CFLAGS="-fembed-bitcode" -sdk $SDK_IPHONEOS -configuration $CONFIGURATION ARCHS="${IPHONEOS_ARCHS}" DEFINES_MODULE="$DEFINEMOUDLE" build
  xcodebuild -project ./$PROJECT_NAME.xcodeproj -target $TARGET_NAME OTHER_CFLAGS="-fembed-bitcode" -sdk $SDK_IPHONESIMULATOR -configuration $CONFIGURATION ARCHS="${SIMULATOR_ARCHS}" DEFINES_MODULE="$DEFINEMOUDLE" build  
}
function buildBundle() {
  xcodebuild -project ./$PROJECT_NAME.xcodeproj -target $RESOURCE_NAME -sdk $SDK_IPHONEOS -configuration $CONFIGURATION ARCHS="${IPHONEOS_ARCHS}" build
}
function copyFramework() {
  # prepare_framework
  mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Headers"
  # Link the "Current" version to "${FRAMEWORK_VERSION}"
  ln -sfh ${FRAMEWORK_VERSION} "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/Current"
  ln -sfh Versions/Current/Headers "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Headers"
  ln -sfh "Versions/Current/${PRODUCT_NAME}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
  # The -a ensures that the headers maintain the source modification date so that we don't constantly
  # cause propagating rebuilds of files that import these headers.
  TARGET_BUILD_DIR="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-${SDK_IPHONEOS}"
  cp -a "${TARGET_BUILD_DIR}/include/" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Headers"
  # compile_framework
  SF_TARGET_NAME=${PROJECT_NAME}
  SF_EXECUTABLE_Name="lib${SF_TARGET_NAME}.a"
  SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"  
  PLATFORM_EXECUTABLE_PATH="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-${SF_SDK_PLATFORM}/${SF_EXECUTABLE_Name}"
  OTHER_PLATFORM_EXECUTABLE_PATH="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-${SF_OTHER_PLATFORM}/${SF_EXECUTABLE_Name}"
  OUTPUT_PATH="${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/${FRAMEWORK_VERSION}/${SF_TARGET_NAME}"
  # Smash the two static libraries into one fat binary and store it in the .framework
  lipo -create "${PLATFORM_EXECUTABLE_PATH}" "${OTHER_PLATFORM_EXECUTABLE_PATH}" -output "${OUTPUT_PATH}"
  # Delete temporary folder if exists
  FINAL_OUTPUT_PATH="output/framework/${SF_WRAPPER_NAME}"
  if [ -d "${FINAL_OUTPUT_PATH}" ]
  mkdir -p "${FINAL_OUTPUT_PATH}"
  then
  rm -dR "${FINAL_OUTPUT_PATH}"
  fi
  # Copy the binary to the other architecture folder to have a complete framework in both.
  cp -a "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}" "${FINAL_OUTPUT_PATH}"


  pathcurrent=`pwd`
  buildMoudleMap $FINAL_OUTPUT_PATH $SF_TARGET_NAME
  cd $pathcurrent

  if [[ ! -d "${FINAL_OUTPUT_PATH}" ]]; then
    echo "${FINAL_OUTPUT_PATH} 不存在————退出"
    exit -1
  fi  
  # 拷贝到 COPYTO 目录   
  copytopath ${SF_WRAPPER_NAME}  "${FINAL_OUTPUT_PATH}" "$pathcurrent"

  exit 0
}

function buildMoudleMap(){
  PARAMETERPATH=$1
  MOUDLENAME=$2  

  MOUDLEMPATH="$PARAMETERPATH/Modules"
  MoudleFolder="Modules"

  ROOTPATH=`pwd`


  echo "$PARAMETERPATH +++++++++++"
  cd "$PARAMETERPATH"
  mkdir "${MoudleFolder}"

  cd "${MoudleFolder}"
  MOUDLEFILE="module.modulemap"
  touch "${MOUDLEFILE}"
  MAPPATH="$MOUDLEFILE"

  if [[ ! -e $MOUDLEFILE ]]; then
    echo "moudle 创建失败"
    exit -1
  fi

  echo "_______$PARAMETERPATH"
  echo "______$MAPPATH"
  echo "framework module $MOUDLENAME {" > $MAPPATH
  echo "umbrella header \"${MOUDLENAME}.h\"" >> $MAPPATH
  echo '' >> "$MAPPATH"
  echo "export *" >> "$MAPPATH"
  echo "module * { export * }" >> "$MAPPATH"
  echo "}" >> "$MAPPATH"
  
}

function copytopath() {
  
 
  TARGETPATH="framework/"
  COPYFROMPATH="output/framework"
  
  echo "准备拷贝 $COPYFROMPATH 到 $TARGETPATH"
    #拷贝
    echo "开始拷贝"
    rm -r $TARGETPATH
    cp -a $COPYFROMPATH $TARGETPATH
    echo "拷贝完成"
    echo "准备删除原目录库" 
    rm -r $COPYFROMPATH
    echo "删除完成"
  
 
}

function copyBundle() {
  # Resources path
  RESOURCE_BUILD_PATH="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-${SF_SDK_PLATFORM}"
  # Resources name
  RESOURCE_PRODUCT_NAME="${RESOURCE_NAME}.bundle"
  # Delete temporary folder if exists
  FINAL_RESOURCE_OUTPUT_PATH="output/resources/${RESOURCE_PRODUCT_NAME}"
  if [ -d "${FINAL_RESOURCE_OUTPUT_PATH}" ]
  mkdir -p "${FINAL_RESOURCE_OUTPUT_PATH}"
  then
  rm -dR "${FINAL_RESOURCE_OUTPUT_PATH}"
  fi
  cp -a "${RESOURCE_BUILD_PATH}/${RESOURCE_PRODUCT_NAME}" "${FINAL_RESOURCE_OUTPUT_PATH}"
}
test -z "${PROJECT_NAME}" || (buildFramework && copyFramework)
test -z "${RESOURCE_NAME}" || (buildBundle && copyBundle)
