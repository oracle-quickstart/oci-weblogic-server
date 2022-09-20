#!/usr/bin/env bash

############################################################
# Build CLI bundle to run SRG dev tests                                                     #
############################################################

cd $(dirname $0)
SCRIPT_DIR=$(pwd)

echo "Cleaning wlsoci binaries folder"
rm -rf ${SCRIPT_DIR}/binaries
echo "Creating wlsoci binaries folder"
mkdir -p ${SCRIPT_DIR}/binaries/tmpbuild
TMP_BUILD=${SCRIPT_DIR}/binaries/tmpbuild

create_cli_bundle()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/edition.tf ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/version.txt ${SCRIPT_DIR}/../terraform/inputs ${TMP_BUILD}
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-terraform.zip *; rm -Rf ${TMP_BUILD}/*)
}

create_cli_bundle

#cleanup
rm -Rf $TMP_BUILD

exit 0
