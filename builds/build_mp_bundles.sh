# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/usr/bin/env bash

############################################################
# help                                                     #
############################################################
help()
{
  echo "Build the Oracle Resource Manager (ORM) bundles to deploy in Marketplace"
  echo
  echo "Arguments: build_mp_bundles.sh -e|--edition <EE|SUITE|SE> -v|--version <12.2.1.4|14.1.1.0> -t|--type <UCM|BYOL> --all"
  echo "options:"
  echo "-e, --edition     WebLogic edition. Supported values are EE, SUITE, or SE. Optional when --all option is provided"
  echo "-v, --version     WebLogic version. Supported values are 12.2.1.4 or 14.1.1.0. Optional when --all option is provided"
  echo "-t, --type        Type of bundle. Supported values are UCM or BYOL. Optional when --all option is provided"
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
        -e|--edition)
            WLS_EDITION="$2"
 	    shift
            ;;
        -v|--version)
            WLS_VERSION="$2"
	    shift
            ;;
        -t|--type)
            BUNDLE_TYPE="$2"
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
  if [ -z "${WLS_EDITION}" ]; then
    echo "WebLogic edition is not provided"
    help
    exit 1
  elif [ "${WLS_EDITION}" != "EE" ] && [ "${WLS_EDITION}" != "SUITE" ] && [ "${WLS_EDITION}" != "SE" ]; then
    echo "Please provide valid WebLogic edition"
    help
    exit 1
  fi

  if [ -z "${WLS_VERSION}" ]; then
    echo "WebLogic version is not provided"
    help
    exit 1
  elif [ "${WLS_VERSION}" != "12.2.1.4" ] && [ "${WLS_VERSION}" != "14.1.1.0" ]; then
    echo "Please provide valid WebLogic version"
    help
    exit 1
  fi

  if [ -z "${BUNDLE_TYPE}" ]; then
    echo "Bundle type is not provided"
    help
    exit 1
  elif [ "${BUNDLE_TYPE}" != "UCM" ] && [ "${BUNDLE_TYPE}" != "BYOL" ]; then
    echo "Please provide valid bundle type"
    help
    exit 1
  fi

  if [ "${BUNDLE_TYPE}" == "UCM" ] && [ "${WLS_EDITION}" == "SE" ]; then
    echo "Standard edition(SE) is not supported for UCM bundle. Please provide BYOL as bundle type"
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
TMP_BUILD=${SCRIPT_DIR}/binaries/tmpbuild
mkdir -p ${SCRIPT_DIR}/binaries/tmpbuild

create_ucm_ee_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/schema.yaml ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_ucm_ee_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_ucm_suite_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SUITE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}  
create_ucm_suite_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SUITE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_ee_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}  
create_byol_ee_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_suite_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SUITE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_suite_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SUITE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_standard_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_standard_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  sed -i '' 's/EE/SE/' ${TMP_BUILD}/edition.tf
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
}

if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
  create_ucm_ee_12214
  create_ucm_ee_14110
  create_ucm_suite_12214
  create_ucm_suite_14110
  create_byol_ee_12214
  create_byol_ee_14110
  create_byol_suite_12214
  create_byol_suite_14110
  create_byol_standard_12214
  create_byol_standard_14110
else
  if [ "${BUNDLE_TYPE}" == "UCM" ]; then
    if [ "${WLS_EDITION}" == "EE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_ucm_ee_12214
      else
        create_ucm_ee_14110
      fi
    elif [ "${WLS_EDITION}" == "SUITE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_ucm_suite_12214
      else
        create_ucm_suite_14110
      fi
    fi
  else
    if [ "${WLS_EDITION}" == "EE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_ee_12214
      else
        create_byol_ee_14110
      fi
    elif [ "${WLS_EDITION}" == "SUITE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_suite_12214
      else
        create_byol_suite_14110
      fi
    else
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_se_12214
      else
        create_byol_se_14110
      fi
    fi
  fi
fi

#cleanup
rm -Rf $TMP_BUILD

exit 0
