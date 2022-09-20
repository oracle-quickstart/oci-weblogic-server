#!/usr/bin/env bash

########################################################################
# Build ORM bundle for developers to test new features  or bug fixes    #
########################################################################

############################################################
# help                                                     #
############################################################
help()
{
  echo "Build the ORM bundles to deploy in Marketplace"
  echo
  echo "Arguments: build.sh -v|--version <12.2.1.4|14.1.1.0> --all"
  echo "options:"
  echo "-v, --version     Weblogic version. Supported values are 12.2.1.4 or 14.1.1.0. Optional when --all option is provided"
  echo "--all             All bundles"
  echo
}

if [ $# -eq 0 ]; then
    help
    exit 1
fi

while [ $# -ne 0 ]
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        -v|--version)
            WLS_VERSION="$2"
	    shift
            ;;
        --all)
	    CREATE_ALL_BUNDLES="true"
	    break
	    ;;
        *)
            help
            exit 1
            ;;
    esac
    shift
done

# validate the input parameters
validate()
{
  if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
     
     echo "Creating all bundles.."
     return
  fi

  if [ -z "${WLS_VERSION}" ]; then
    echo "wls version is not provided"
    help
    exit 1
  elif [ "${WLS_VERSION}" != "12.2.1.4" ] && [ "${WLS_VERSION}" != "14.1.1.0" ]; then
    echo "Please provide valid wls version"
    help
    exit 1
  fi
}

#Run validation for the input parameters
validate

cd $(dirname $0)
SCRIPT_DIR=$(pwd)

echo "Cleaning wlsoci binaries folder"
rm -rf ${SCRIPT_DIR}/binaries
echo "Creating wlsoci binaries folder"
mkdir -p ${SCRIPT_DIR}/binaries/tmpbuild
TMP_BUILD=${SCRIPT_DIR}/binaries/tmpbuild

create_12214_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/schema.yaml ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_14110_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 

if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
  create_12214_bundle
  create_14110_bundle
else
  if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
    create_12214_bundle
  else
    create_14110_bundle
  fi
fi

#cleanup
rm -Rf $TMP_BUILD

exit 0
