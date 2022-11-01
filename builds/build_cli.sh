# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/usr/bin/env bash

############################################################
# Build CLI bundle to run SRG dev tests                                                     #
############################################################

############################################################
# help                                                     #
############################################################
help()
{
  echo
  echo "Arguments: build_cli.sh -t|--scripts_version"
  echo "options:"
  echo "-t, --scripts_version     VM scripts version"
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
        -t|--scripts_version)
            SCRIPTS_VERSION="$2"
            shift
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

create_cli_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/inputs ${TMP_BUILD}
  replace_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-terraform.zip *; rm -Rf ${TMP_BUILD}/*)
}

#need to change it to false after RM UI fix
replace_variables()
{
  sed -i '/variable "generate_dg_tag" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = false' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = \"'"$SCRIPTS_VERSION"'\"' ${TMP_BUILD}/variables.tf
}


create_cli_bundle

#cleanup
rm -Rf $TMP_BUILD

exit 0
