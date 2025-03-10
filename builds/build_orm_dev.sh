#!/usr/bin/env bash

# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#######################################################################################################
# Build the Oracle Resource Manager (ORM) bundles for developers to test new features or bug fixes    #
#######################################################################################################

############################################################
# help                                                     #
############################################################
help()
{
  echo "Build the Oracle Resource Manager (ORM) bundles for developers to deploy in Marketplace"
  echo
  echo "Arguments: build_orm_dev.sh -v|--version <12.2.1.4|14.1.1.0|14.1.2.0> -t|--scripts_version --all"
  echo "options:"
  echo "-v, --version             WebLogic version. Supported values are 12.2.1.4,14.1.2.0 or 14.1.1.0 Optional when --all option is provided"
  echo "-t, --scripts_version     VM scripts version"
  echo "--all                     All bundles"
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
        -t|--scripts_version)
            SCRIPTS_VERSION="$2"
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

  if [ -z "${SCRIPTS_VERSION}" ]; then
    echo "vm scripts version is not provided"
    help
    exit 1
  fi

  if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
     echo "Creating all bundles.."
     return
  fi

  if [ -z "${WLS_VERSION}" ]; then
    echo "WebLogic version is not provided"
    help
    exit 1
  elif [ "${WLS_VERSION}" != "12.2.1.4" ] && [ "${WLS_VERSION}" != "14.1.2.0" ] && [ "${WLS_VERSION}" != "14.1.1.0" ]; then
    echo "Please provide valid WebLogic version"
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

create_12214_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/schema.yaml ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_14110_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-14110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_14120_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}

#need to change it to false after RM UI fix
replace_12214_variables()
{
  sed -i '/variable "generate_dg_tag" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = \"'"$SCRIPTS_VERSION"'\"' ${TMP_BUILD}/variables.tf
}

#need to change it to false after RM UI fix
replace_14110_variables()
{
  sed -i '/variable "generate_dg_tag" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = \"'"$SCRIPTS_VERSION"'\"' ${TMP_BUILD}/variables.tf
}
replace_14120_variables()
{
  sed -i '/variable "generate_dg_tag" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = \"'"$SCRIPTS_VERSION"'\"' ${TMP_BUILD}/variables.tf
}

if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
  create_12214_bundle
  create_14110_bundle
  create_14120_bundle
else
  if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
      create_12214_bundle
  elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
      create_14120_bundle
  else
      create_14110_bundle
  fi
fi

#cleanup
rm -Rf $TMP_BUILD

exit 0
