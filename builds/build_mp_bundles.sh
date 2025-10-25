#!/usr/bin/env bash

# Copyright (c) 2023, 2025, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

############################################################
# help                                                     #
############################################################
help()
{
  echo "Build the Oracle Resource Manager (ORM) bundles to deploy in Marketplace"
  echo
  echo "Arguments: build_mp_bundles.sh -e|--edition <EE|SUITE|SE> -v|--version <12.2.1.4|14.1.1.0|14.1.2.0|15.1.1.0> -t|--type <UCM|BYOL> --all"
  echo "options:"
  echo "-e, --edition     WebLogic edition. Supported values are EE, SUITE, or SE. Optional when --all option is provided"
  echo "-v, --version     WebLogic version. Supported values are 12.2.1.4 or 14.1.1.0 or 14.1.2.0 or 15.1.1.0. Optional when --all option is provided"
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
  elif [ "${WLS_VERSION}" != "12.2.1.4" ] && [ "${WLS_VERSION}" != "14.1.1.0" ] && [ "${WLS_VERSION}" != "14.1.2.0" ] && [ "${WLS_VERSION}" != "15.1.1.0" ]; then
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
  cp -Rf ${SCRIPT_DIR}/../terraform/schema.yaml ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_ee_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_ucm_ee_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_ee_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_ucm_ee_14120()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_ee_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_ucm_ee_15110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_15110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_ee_15110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-ucm-mp-15110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_ucm_suite_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_suite_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}  
create_ucm_suite_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_suite_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_ucm_suite_14120()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_suite_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_ucm_suite_15110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_15110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_ucm_suite_15110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-ucm-mp-15110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_ee_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_ee_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}  
create_byol_ee_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_ee_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_ee_14120()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_ee_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_ee_15110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_15110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_ee_15110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-ee-byol-mp-15110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_suite_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_suite_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_suite_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_suite_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
} 
create_byol_suite_14120()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_suite_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_suite_15110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_15110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_suite_15110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-suite-byol-mp-15110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_standard_12214()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_se_12214_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-12214.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_standard_14110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_se_14110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-14110.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_standard_14120()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_14120.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_se_14120_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-14120.zip *; rm -Rf ${TMP_BUILD}/*)
}
create_byol_standard_15110()
{
  cp -Rf ${SCRIPT_DIR}/../terraform/modules ${SCRIPT_DIR}/../terraform/*.tf ${SCRIPT_DIR}/../terraform/schema_15110.yaml ${TMP_BUILD}
  cp -f ${SCRIPT_DIR}/../terraform/orm/orm_provider.tf ${TMP_BUILD}/provider.tf
  replace_byol_se_15110_variables
  (cd ${TMP_BUILD}; zip -r ${SCRIPT_DIR}/binaries/wlsoci-resource-manager-se-byol-mp-15110.zip *; rm -Rf ${TMP_BUILD}/*)
}

replace_byol_ee_12214_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_ee_14110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_14110.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_14110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_ee_14120_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_14120.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_14120.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_ee_15110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"15.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_15110.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_15110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_se_12214_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_se_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema.yaml
  sed -i 's/#- ${use_autoscaling}/- ${use_autoscaling}/' ${TMP_BUILD}/schema.yaml
  sed -i ':a;$!{N;ba};s/- ${use_autoscaling}/#- ${use_autoscaling}/1' ${TMP_BUILD}/schema.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_se_14110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_se_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i 's/#- ${use_autoscaling}/- ${use_autoscaling}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i ':a;$!{N;ba};s/- ${use_autoscaling}/#- ${use_autoscaling}/1' ${TMP_BUILD}/schema_14110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_se_14120_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_se_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i 's/#- ${use_autoscaling}/- ${use_autoscaling}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i ':a;$!{N;ba};s/- ${use_autoscaling}/#- ${use_autoscaling}/1' ${TMP_BUILD}/schema_14120.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_se_15110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_se_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"15.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i 's/#- ${use_autoscaling}/- ${use_autoscaling}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i ':a;$!{N;ba};s/- ${use_autoscaling}/#- ${use_autoscaling}/1' ${TMP_BUILD}/schema_15110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_suite_12214_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_suite_14110_variables()
{ 
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_14110.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_14110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_suite_14120_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_14120.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_14120.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_byol_suite_15110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"15.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_instance_image_id" {/!b;n;n;n;cdefault = '"${ucm_instance_image_id}"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_id" {/!b;n;n;n;cdefault = '"$ucm_listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "ucm_listing_resource_version" {/!b;n;n;n;cdefault = '"$ucm_listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i 's/#- ${image_mode}/- ${image_mode}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i 's/#- ${terms_and_conditions}/- ${terms_and_conditions}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i ':a;$!{N;ba};s/- ${image_mode}/#- ${image_mode}/2' ${TMP_BUILD}/schema_15110.yaml
  sed -i ':a;$!{N;ba};s/- ${terms_and_conditions}/#- ${terms_and_conditions}/2' ${TMP_BUILD}/schema_15110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_suite_12214_variables()
{  
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_suite_14110_variables()
{ 
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_suite_14120_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_suite_15110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i 's/default     = "EE"/default     = "SUITE"/' ${TMP_BUILD}/edition.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"15.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_suite_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_ee_12214_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_ee_14110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_ee_14120_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"14.1.2.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_14120.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}
replace_ucm_ee_15110_variables()
{
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_ucm.tfvars
  get_mp_values
  sed -i '/variable "tf_script_version" {/!b;n;n;n;cdefault = '"$tf_script_version"'' ${TMP_BUILD}/variables.tf
  sed -i '/variable "wls_version" {/!b;n;n;n;cdefault = \"15.1.1.0\"' ${TMP_BUILD}/weblogic_variables.tf
  sed -i '/variable "instance_image_id" {/!b;n;n;n;cdefault = '"$instance_image_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "use_marketplace_image" {/!b;n;n;n;cdefault = '"true"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_id" {/!b;n;n;n;cdefault = '"$listing_id"'' ${TMP_BUILD}/mp_variables.tf
  sed -i '/variable "listing_resource_version" {/!b;n;n;n;cdefault = '"$listing_resource_version"'' ${TMP_BUILD}/mp_variables.tf
  sed -i 's/#- ${instance_image_id}/- ${instance_image_id}/' ${TMP_BUILD}/schema_15110.yaml
  sed -i '/main_mktpl_image/ { n; s/ocid                  = ""/ocid = '"${instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
  export TF_VAR_FILE=${SCRIPT_DIR}/../terraform/images/mp_image_ee_byol.tfvars
  get_mp_values
  sed -i '/ucm_image/ { n; s/ocid                  = ""/ocid = '"${ucm_instance_image_id}"'/; }' ${TMP_BUILD}/oci_images.tf
}

get_mp_values()
{
  export tf_script_version=`cat ${TF_VAR_FILE} | grep -w "tf_script_version" | cut -d'=' -f2`
  export listing_id=`cat ${TF_VAR_FILE} | grep -w "listing_id" | cut -d'=' -f2`
  export listing_resource_version=`cat ${TF_VAR_FILE} | grep -w "listing_resource_version" | cut -d'=' -f2`
  export instance_image_id=`cat ${TF_VAR_FILE} | grep -w "instance_image_id" | cut -d'=' -f2`
  export ucm_listing_id=`cat ${TF_VAR_FILE} | grep -w "ucm_listing_id" | cut -d'=' -f2`
  export ucm_listing_resource_version=`cat ${TF_VAR_FILE} | grep -w "ucm_listing_resource_version" | cut -d'=' -f2`
  export ucm_instance_image_id=`cat ${TF_VAR_FILE} | grep -w "ucm_instance_image_id" | cut -d'=' -f2`
}

if [ "${CREATE_ALL_BUNDLES}" == "true" ]; then
  create_ucm_ee_12214
  create_ucm_ee_14110
  create_ucm_ee_14120
  create_ucm_ee_15110
  create_ucm_suite_12214
  create_ucm_suite_14110
  create_ucm_suite_14120
  create_ucm_suite_15110
  create_byol_ee_12214
  create_byol_ee_14110
  create_byol_ee_14120
  create_byol_ee_15110
  create_byol_suite_12214
  create_byol_suite_14110
  create_byol_suite_14120
  create_byol_suite_15110
  create_byol_standard_12214
  create_byol_standard_14110
  create_byol_standard_14120
  create_byol_standard_15110
else
  if [ "${BUNDLE_TYPE}" == "UCM" ]; then
    if [ "${WLS_EDITION}" == "EE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_ucm_ee_12214
      elif [ "${WLS_VERSION}" == "14.1.1.0" ]; then
        create_ucm_ee_14110
      elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
        create_ucm_ee_14120
      else
	      create_ucm_ee_15110
      fi

    elif [ "${WLS_EDITION}" == "SUITE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_ucm_suite_12214
      elif [ "${WLS_VERSION}" == "14.1.1.0" ]; then
        create_ucm_suite_14110
      elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
        create_ucm_suite_14120
      else
	      create_ucm_suite_15110
      fi
    fi
  else
    if [ "${WLS_EDITION}" == "EE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_ee_12214
      elif [ "${WLS_VERSION}" == "14.1.1.0" ]; then
        create_byol_ee_14110
      elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
        create_byol_ee_14120
      else
	      create_byol_ee_15110
      fi
    elif [ "${WLS_EDITION}" == "SUITE" ]; then
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_suite_12214
      elif [ "${WLS_VERSION}" == "14.1.1.0" ]; then
        create_byol_suite_14110
      elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
        create_byol_suite_14120
      else
	      create_byol_suite_15110
      fi
    else
      if [ "${WLS_VERSION}" == "12.2.1.4" ]; then
        create_byol_se_12214
      elif [ "${WLS_VERSION}" == "14.1.1.0" ]; then
        create_byol_se_14110
      elif [ "${WLS_VERSION}" == "14.1.2.0" ]; then
        create_byol_se_14120
      else
	      create_byol_se_15110
      fi
    fi
  fi
fi

#cleanup
rm -Rf $TMP_BUILD

exit 0
