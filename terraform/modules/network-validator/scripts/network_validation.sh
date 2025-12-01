#!/usr/bin/env bash
#
# Copyright (c) 2023, 2025, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ############################################################################
# Script to validate existing subnets, and optionally network security groups meet the pre-requisite for
# provisioning and proper functioning of WebLogic for OCI instance.
# ############################################################################
#

version="1.1.1"

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
DB_PORT=1521
ATP_DB_PORT=1522
SSH_PORT=22
T3_PORT=9071
WLS_LB_PORT=7003
LB_PORT=443
ADMIN_HTTP_PORT=7001
ADMIN_HTTPS_PORT=7002
IDCS_PORT=
WLS_SUBNET_OCID=""
BASTION_SUBNET_OCID=""
BASTION_HOST_IP=""
LB_SUBNET_1_OCID=""
LB_SUBNET_2_OCID=""
FSS_SUBNET_OCID=""
ADMIN_SRV_NSG_OCID=""
MANAGED_SRV_NSG_OCID=""
BASTION_NSG_OCID=""
LB_NSG_OCID=""
FSS_NSG_OCID=""
LPG_OCID=""
ALL_IPS="0.0.0.0/0"
LB_SOURCE_CIDR=""
SECURE_MODE="false"
NETWORK_VALIDATION_MSG="Fix the network validation script errors and re-run the script in the cloud shell"

debug=false
args=()

function ip_to_int() {
  local ip_addr="${1}"
  local ip_1 ip_2 ip_3 ip_4

  ip_1=$(echo "${ip_addr}" | cut -d'.' -f1)
  ip_2=$(echo "${ip_addr}" | cut -d'.' -f2)
  ip_3=$(echo "${ip_addr}" | cut -d'.' -f3)
  ip_4=$(echo "${ip_addr}" | cut -d'.' -f4)

  echo $(( ip_1 * 256**3 + ip_2 * 256**2 + ip_3 * 256 + ip_4 ))
}

####################################################
# Determine whether IP address is in the specified subnet.
#
# Args:
#   cidr_subnet: Subnet, in CIDR notation.
#   ip_addr: IP address to check.
#
# Returns:
#   0|1
####################################################
function in_cidr_range() {
  local cidr_subnet="${1}"
  local ip_addr="${2}"
  local subnet_ip cidr_mask netmask ip_addr_subnet subnet rval

  subnet_ip=$(echo "${cidr_subnet}" | cut -d'/' -f1)
  cidr_mask=$(echo "${cidr_subnet}" | cut -d'/' -f2)
  ip_addr_ip=$(echo "${ip_addr}" | cut -d'/' -f1)

  netmask=$(( 0xFFFFFFFF << $(( 32 - ${cidr_mask} )) ))

  # Apply netmask to both the subnet IP and the given IP address
  ip_addr_subnet=$(( netmask & $(ip_to_int ${ip_addr_ip}) ))
  subnet=$(( netmask & $(ip_to_int ${subnet_ip}) ))

  # Subnet IPs will match if given IP address is in CIDR subnet
  [ "${ip_addr_subnet}" == "${subnet}" ] && rval=0 || rval=1

  return $rval
}

####################################################
# Validates if one of service or nat gateways exist in the VCN of the specified private subnet.
#
# Returns:
#   0|1
####################################################
function validate_service_or_nat_gw_exist() {
  local vcn_ocid=""
  local vcn_compartment_ocid=""

  is_private_subnet=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["prohibit-public-ip-on-vnic"]')

  if [[ $is_private_subnet = true ]]
  then
    vcn_ocid=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["vcn-id"]')
    vcn_compartment_ocid=$(oci network vcn get --vcn-id ${vcn_ocid} | jq -r '.data["compartment-id"]')
    # Check if NAT gateway exists in the VCN
    res=$(oci network nat-gateway list --compartment-id ${vcn_compartment_ocid} --vcn-id ${vcn_ocid})
    nat_gw_found=$(if [[ -n $res ]]; then echo 0; else echo 1; fi)

    # Check if Service gateway exists in the VCN
    res=$(oci network service-gateway list --compartment-id ${vcn_compartment_ocid} --vcn-id ${vcn_ocid})
    svc_gw_found=$(if [[ -n $res ]]; then echo 0; else echo 1; fi)

    # One of NAT or Service Gateway must exist
    if [[ $nat_gw_found -ne 0 ]] && [[ $svc_gw_found -ne 0 ]]
    then
      echo 1
      return
    fi

    # WLS subnet should be using either NAT or service gateway or both in its route table
    rt_ocid=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["route-table-id"]')
    rt_rules=$(oci network route-table get --rt-id ${rt_ocid} | jq -r '.data["route-rules"]')
    rt_rules_count=$(echo $rt_rules | jq '.|length')

    nat=""
    svc=""
    nat_gw_id=""
    svc_gw_id=""

    for ((i = 0 ; i < $rt_rules_count ; i++))
    do
      network_entity_ocid=$(echo $rt_rules | jq -r --arg i "$i" '.[$i|tonumber]["network-entity-id"]')
      nat_id=$(echo $network_entity_ocid | grep natgateway)
      if [[ -n $nat_id ]]; then nat_gw_id=$nat_id; fi
      svc_id=$(echo $network_entity_ocid | grep servicegateway)
      if [[ -n $svc_id ]]; then svc_gw_id=$svc_id; fi
    done

    if [[ (-z $nat_gw_id  && -z $svc_gw_id) ]]; then
      echo 2
      return
    fi

    # If WLS subnet route table has a rule to use service gateway then it should be using
    # all-<region-code>-services-in-oracle-services-network destination
    if [[ -n $svc_gw_id ]]
    then
      is_all_services_name=$(oci network service-gateway get --service-gateway-id $svc_gw_id | jq -r '.data.services[0]["service-name"]' | grep -i "all.*services in oracle services network")
      if [[ -z $is_all_services_name ]]
      then
        echo 3
        return
      fi
      for ((k = 0 ; k < $rt_rules_count ; k++))
      do
        network_entity_ocid=$(echo $rt_rules | jq -r --arg i "$k" '.[$i|tonumber]["network-entity-id"]')
        res=$(echo $network_entity_ocid | grep servicegateway)
        if [[ -n $res ]]
        then
          all_services_destination=$(echo $rt_rules | jq -r --arg i "$k" '.[$i|tonumber].destination'  | grep -i "all-.*-services-in-oracle-services-network")
          if [[ -z $all_services_destination ]]
          then
            echo 4
            return
          fi
        fi
      done
    fi
  fi
  echo 0
}

###########################################################
# Validates if the Subnet has a specific Route Rule for LPG.
# Args:
#   subnet_ocid: OCID of the VCN Subnet
#   cidr_subnet: CIDR subnet of the VCN
#
# Returns:
#   0|2|4
############################################################
function validate_lpg_route_rule() {
  local subnet_ocid=$1
  local cidr_subnet=$2

  #Check if the Subnet's route rule contains LPG entry
  rt_ocid=$(oci network subnet get --subnet-id ${subnet_ocid} | jq -r '.data["route-table-id"]')
  rt_rules=$(oci network route-table get --rt-id ${rt_ocid} | jq -r '.data["route-rules"]')
  rt_rules_count=$(echo $rt_rules | jq '.|length')

  lpg=""
  lpg_gw_id=""

  for ((i = 0 ; i < $rt_rules_count ; i++))
  do
    network_entity_ocid=$(echo $rt_rules | jq -r --arg i "$i" '.[$i|tonumber]["network-entity-id"]')
    lpg_id=$(echo $network_entity_ocid | grep localpeeringgateway)
    if [[ -n $lpg_id ]]; then lpg_gw_id=$lpg_id; fi
  done

  if [[ -z $lpg_gw_id ]]; then
    echo 2
    return
  else
    for ((k = 0 ; k < $rt_rules_count ; k++))
    do
      network_entity_ocid=$(echo $rt_rules | jq -r --arg i "$k" '.[$i|tonumber]["network-entity-id"]')
      res=$(echo $network_entity_ocid | grep localpeeringgateway)
      if [[ -n $res ]]
      then
        cidr_range=$(echo $rt_rules | jq -r --arg i "$k" '.[$i|tonumber].destination')
        res=$(in_cidr_range ${cidr_subnet} ${cidr_range})
        if [[ $res -eq 0 ]]
        then
          echo 0
          return
        fi
      fi
    done

    # executes only if loop never returned
    echo 4
  fi
}

####################################################
# Validates if the internet gateway exists in the VCN of WLS subnet.
# Without Internet gateway in WLS VCN, SSH access from ORM will not work.
# When using terraform CLI from within private network, internet gateway is not required.
# Hence this check will give a warning and not an error.
#
# Returns:
#   0|1
####################################################
function validate_internet_gw_exist() {
  local vcn_ocid=""
  local vcn_compartment_ocid=""

  vcn_ocid=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["vcn-id"]')
  vcn_compartment_ocid=$(oci network vcn get --vcn-id ${vcn_ocid} | jq -r '.data["compartment-id"]')

  # Check if Service gateway exists in the VCN
  res=$(oci network internet-gateway list --compartment-id ${vcn_compartment_ocid} --vcn-id ${vcn_ocid})

  if [[ -n $res ]]; then
    echo 0
  else
    echo 1
  fi
}

####################################################
# Checks if specified port is open to specified source CIDR in the ingress rules of specified seclist or nsg.
#
# Args:
#     seclist_or_nsg_ocid:  OCID for the security list or nsg.
#     port: destination port to check
#     source: Source CIDR (either block/range of IPs or single IP (with /32 suffix)
#     ocid_type: Valid values: "nsg" for Network Security Group OCID, "seclist" for Security List OCID (default)
#
# Returns:
#   0|1
####################################################
function check_tcp_port_open_in_seclist_or_nsg() {
  local seclist_or_nsg_ocid=$1
  local port=$2
  local source=$3
  local ocid_type=$4
  local port_is_open=false
  local tcp_protocol="6"
  local ingress_rules_count=0
  declare -A nsg_sec_list_array

  if [[ $ocid_type = "nsg" ]]; then
      ingress_rules=$(oci network nsg rules list --nsg-id $seclist_or_nsg_ocid --direction INGRESS | jq -r '.data')
  else
      ingress_rules=$(oci network security-list get --security-list-id $seclist_or_nsg_ocid | jq -r '.data["ingress-security-rules"]')
  fi

  ingress_rules_count=$(echo $ingress_rules | jq '.|length')
  if [[ $ingress_rules_count != "" ]]; then
    for ((j = 0 ; j < $ingress_rules_count ; j++))
    do
      ingress_protocol=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber].protocol')
      ingress_source=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber].source')
      ingress_source_type=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]."source-type"')
      tcp_options=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]')
      port_min=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]["destination-port-range"].min')
      port_max=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]["destination-port-range"].max')

      if [[ $ingress_source_type != "CIDR_BLOCK" ]]
      then
        nsg_sec_list_array[$j]="WARNING: Source type is either NSG or Service. Skipping the validation check for ${ingress_source}."
        continue
      fi

      source_in_cidr_range=1
      if [[ $source = "0.0.0.0/0" ]]
      then
        if [[ $ingress_source = $source ]]
        then
          source_in_cidr_range=0
        else
          source_in_cidr_range=1
        fi
      elif [[ $source = "" ]]
      then
        source_in_cidr_range=0
      else
        source_in_cidr_range=$(in_cidr_range $ingress_source $source ; echo $?)
      fi

      if [[ ($ingress_protocol = "all" || $ingress_protocol = $tcp_protocol ) && ( $tcp_options = "null" || ( $port -ge $port_min && $port -le $port_max ) ) && $source_in_cidr_range -eq 0 ]]
      then
        port_is_open=true
        echo 0
        return
      fi
    done
  fi
  if [[ ${#nsg_sec_list_array[@]} != 0 ]]
  then
    echo "${nsg_sec_list_array[@]}"
  else
    echo 1
  fi
}

####################################################
# Checks if specified UDP port is open to specified source CIDR in the ingress rules of specified seclist or nsg.
#
# Args:
#     seclist_or_nsg_ocid:  OCID for the security list or nsg.
#     port: destination port to check
#     source: Source CIDR (either block/range of IPs or single IP (with /32 suffix)
#     ocid_type: Valid values: "nsg" for Network Security Group OCID, "seclist" for Security List OCID (default)
#
# Returns:
#   0|1
####################################################
function check_udp_port_open_in_seclist_or_nsg() {
  local seclist_or_nsg_ocid=$1
  local port=$2
  local source=$3
  local ocid_type=$4
  local port_is_open=false
  local udp_protocol="17"
  local ingress_rules_count=0

  if [[ $ocid_type = "nsg" ]]; then
    ingress_rules=$(oci network nsg rules list --nsg-id $seclist_or_nsg_ocid --direction INGRESS | jq -r '.data')
  else
    ingress_rules=$(oci network security-list get --security-list-id $seclist_or_nsg_ocid | jq -r '.data["ingress-security-rules"]')
  fi

  ingress_rules_count=$(echo $ingress_rules | jq '.|length')
  if [[ $ingress_rules_count -ne 0 ]]; then
    for ((j = 0 ; j < $ingress_rules_count ; j++))
    do
      ingress_protocol=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber].protocol')
      ingress_source=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber].source')
      ingress_source_type=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]."source-type"')
      udp_options=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["udp-options"]')
      port_min=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["udp-options"]["destination-port-range"].min')
      port_max=$(echo $ingress_rules | jq -r --arg i "$j" '.[$i|tonumber]["udp-options"]["destination-port-range"].max')

      if [[ $ingress_source_type != "CIDR_BLOCK" ]]
      then
        nsg_sec_list_array[$j]="WARNING: Source type is either NSG or Service. Skipping the validation check for ${ingress_source}."
        continue
      fi

      source_in_cidr_range=1
      if [[ $source = "0.0.0.0/0" ]]
      then
        if [[ $ingress_source = $source ]]
        then
          source_in_cidr_range=0
        else
          source_in_cidr_range=1
        fi
      else
        source_in_cidr_range=$(in_cidr_range $ingress_source $source ; echo $?)
      fi

      if [[ ($ingress_protocol = "all" || $ingress_protocol = $udp_protocol ) && ( $udp_options = "null" || ( $port -ge $port_min && $port -le $port_max ) ) && $source_in_cidr_range -eq 0 ]]
      then
        port_is_open=true
        echo 0
        return
      fi
    done
  fi
  if [[ ${#nsg_sec_list_array[@]} != 0 ]]
  then
    echo "${nsg_sec_list_array[@]}"
  else
    echo 1
  fi
}
###################################################
# Checks if there is an egress rule to  ensure that the network can establish outbound communication to any destination, utilizing all available protocols and ports.
# Args:
#     seclist_or_nsg_ocid:  OCID for the security list or nsg.
#     ocid_type: Valid values: "nsg" for Network Security Group OCID, "seclist" for Security List OCID (default)
# Returns:
#   0|1|Content of nsg_sec_list_array
###################################################
function check_egress_all_traffic_in_nsg_or_seclist() {
    local nsg_ocid_or_sec_list=$1
    local icmp_protocol="1"
    local port_is_open=false
    local egress_rules_count=0
    local ocid_type=$2
    declare -A nsg_sec_list_array

    if [[ $ocid_type == "nsg" ]]; then
        egress_rules=$(oci network nsg rules list --nsg-id $nsg_ocid_or_sec_list --direction EGRESS | jq -r '.data')
    else
        egress_rules=$(oci network security-list get --security-list-id $nsg_ocid_or_sec_list | jq -r '.data["egress-security-rules"]')
    fi
    egress_rules_count=$(echo $egress_rules | jq '. | length')

    if [[ $egress_rules_count -gt 0 ]]; then
        for ((j = 0; j < egress_rules_count; j++)); do
            egress_protocol=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber].protocol')
            egress_destination=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber].destination')
            egress_destination_type=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber]."destination-type"')


            if [[ $egress_destination_type != "CIDR_BLOCK" ]]; then
                nsg_sec_list_array[$j]="WARNING: Destinantion type is either NSG or Service. Skipping the validation check for ${egress_destination}."
                continue
            fi

            if [[ $egress_destination == "0.0.0.0/0" && ( $egress_protocol == "all" || $egress_protocol == $icmp_protocol ) ]]; then
                egress_is_open=true
                echo 0
                return
            fi
        done
    fi

    if [[ ${#nsg_sec_list_array[@]} != 0 ]]; then
        echo "${nsg_sec_list_array[@]}"
    else
        echo 1
    fi
}

###################################################
# Checks if there is an egress rule to  ensure that the network can establish outbound communication to the Database on the specific port.
# Args:
#     seclist_or_nsg_ocid:  OCID for the security list or nsg.
#     ocid_type: Valid values: "nsg" for Network Security Group OCID, "seclist" for Security List OCID (default)
#     db_cidr: CIDR block of the Database
#     db_port: Database Port
# Returns:
#   0|1|Content of nsg_sec_list_array
###################################################
function check_egress_db_traffic_in_nsg_or_seclist() {
    local nsg_ocid_or_sec_list=$1
    local db_cidr=$3
    local db_port=$4
    local icmp_protocol="1"
    local port_is_open=false
    local egress_rules_count=0
    local ocid_type=$2
    declare -A nsg_sec_list_array

    if [[ $ocid_type == "nsg" ]]; then
        egress_rules=$(oci network nsg rules list --nsg-id $nsg_ocid_or_sec_list --direction EGRESS | jq -r '.data')
    else
        egress_rules=$(oci network security-list get --security-list-id $nsg_ocid_or_sec_list | jq -r '.data["egress-security-rules"]')
    fi
    egress_rules_count=$(echo $egress_rules | jq '. | length')

    if [[ $egress_rules_count -gt 0 ]]; then
        for ((j = 0; j < egress_rules_count; j++)); do
            egress_protocol=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber].protocol')
            egress_destination=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber].destination')
            egress_destination_type=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber]."destination-type"')
            tcp_options=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]')
            port_min=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]["destination-port-range"].min')
            port_max=$(echo $egress_rules | jq -r --arg i "$j" '.[$i|tonumber]["tcp-options"]["destination-port-range"].max')


            if [[ $egress_destination_type != "CIDR_BLOCK" ]]; then
                nsg_sec_list_array[$j]="WARNING: Destinantion type is either NSG or Service. Skipping the validation check for ${egress_destination}."
                continue
            fi

            if [[ $egress_protocol == "6"  && $egress_destination == "$db_cidr" && ( $db_port -ge $port_min && $db_port -le $port_max )  ]]
            then
              port_is_open=true
              echo 0
              return
            fi
        done
    fi

    if [[ ${#nsg_sec_list_array[@]} != 0 ]]; then
        echo "${nsg_sec_list_array[@]}"
    else
        echo 1
    fi
}


####################################################
# Validates if the specified destination TCP/UDP port is open for the specified subnet CIDR in the specified subnet.
#
# Args:
#     subnet:       Subnet OCID
#     port:         Destination port
#     source_cidr:  Source CIDR
#     protocol:     TCP(Default)/UDP
#
# Returns:
#   0|1
####################################################
function validate_subnet_port_access() {
  local port_found_open=1
  local subnet=$1
  local port=$2
  local source_cidr=$3
  local protocol=$4 # Default protocol is TCP, if it is UDP then need to pass this param

  sec_lists=$(oci network subnet get --subnet-id ${subnet} | jq -c '.data["security-list-ids"]')

  # Convert to bash array
  declare -A seclists_array

  while IFS="=" read -r key value
  do
      seclists_array[$key]="$value"
  done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' <<< "$sec_lists")

  # Check the ingress rules for specified destination port is open for access by source CIDR
  for seclist_ocid in "${seclists_array[@]}"
  do
    if [[ $port_found_open -ne 0 ]]; then
      if [[ -z $protocol ]]; then # default is TCP
          port_found_open=$(check_tcp_port_open_in_seclist_or_nsg $seclist_ocid "${port}" "$source_cidr" "seclist")
      else # protocol param is non empty then udp
          port_found_open=$(check_udp_port_open_in_seclist_or_nsg $seclist_ocid "${port}" "$source_cidr" "seclist")
      fi
    fi
  done
  echo $port_found_open
}
####################################################
# Validates if egress rule is present to allow all traffic on all ports in the specified subnet.
#
# Args:
#     subnet: Subnet OCID
# Returns:
#   0|1
####################################################
function validate_egress_rule() {
  local port_found_open=1
  local subnet=$1

  sec_lists=$(oci network subnet get --subnet-id ${subnet} | jq -c '.data["security-list-ids"]')

  declare -A seclists_array

  while IFS="=" read -r key value
  do
      seclists_array[$key]="$value"
  done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' <<< "$sec_lists")
   # Check the ingress rules for specified destination port is open for access by source CIDR
  for seclist_ocid in "${seclists_array[@]}"
  do
    if [[ $port_found_open -ne 0 ]]; then
      port_found_open=$(check_egress_all_traffic_in_nsg_or_seclist $seclist_ocid  "seclist")
    fi
  done
  echo $port_found_open
}

###################################################
# Validates if egress rule is present to allow DB traffic for WLS subnet.
#
# Args:
#     subnet: Subnet OCID
#     db_cidr_block: CIDR block for the DB subnet
#     port: Database port
# Returns:
#   0|1
####################################################
function validate_db_egress_rule() {
  local port_found_open=1
  local subnet=$1
  local db_cidr_block=$2
  local port=$3

  sec_lists=$(oci network subnet get --subnet-id ${subnet} | jq -c '.data["security-list-ids"]')

  declare -A seclists_array

  while IFS="=" read -r key value
  do
      seclists_array[$key]="$value"
  done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' <<< "$sec_lists")
   # Check the ingress rules for specified destination port is open for access by source CIDR
  for seclist_ocid in "${seclists_array[@]}"
  do
    if [[ $port_found_open -ne 0 ]]; then
      port_found_open=$(check_egress_db_traffic_in_nsg_or_seclist $seclist_ocid  "seclist" $db_cidr_block $port)
    fi
  done
  echo $port_found_open
}

####################################################
# Validates if the ATP_PORT is open for the WLS subnet CIDR.
# This is applicable for ATP DB with private endpoint only.
# Args:
#     subnet_id: ATP DB private endpoint subnet OCID
#     atp_id: ATP DB OCID to check port access
#     source_cidr: WLS subnet CIDR
#
# Returns:
#   0|1
####################################################
function validate_atpdb_port_access() {
  local port_found_open=1
  local subnet_id=$1
  local atpdb_id=$2
  local source_cidr=$3

  nsg_list=$(oci db autonomous-database get --autonomous-database-id ${atpdb_id} | jq -c '.data["nsg-ids"]')

  if [[ $nsg_list != "null" ]]; then
    # Convert to bash array
    declare -A nsg_list_array

    while IFS="=" read -r key value
    do
      nsg_list_array[$key]="$value"
    done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' <<< "$nsg_list")

    # Check the NSG ingress rules for specified destination port is open for access by source CIDR
    for nsg_ocid in "${nsg_list_array[@]}"
    do
      if [[ $port_found_open -ne 0 ]]; then
        port_found_open=$(check_tcp_port_open_in_seclist_or_nsg $nsg_ocid "${ATP_DB_PORT}" "$source_cidr" "nsg")
      fi
    done
  fi
  if [[ port_found_open -ne 0 ]]; then
    # If ATP port is not opened by NSG ingress rules, check subnet security list
    # doc: "if you choose a subnet with a security list, the security rules for the ATP database
    # will be a union of the rules in the security list and the NSGs."
    port_found_open=$(validate_subnet_port_access ${subnet_id} ${ATP_DB_PORT} ${source_cidr})
  fi

  echo $port_found_open
}

####################################################
# Validates if the DB_PORT is open for the WLS subnet CIDR.
# Args:
#     subnet_id: OCI DB subnet OCID
#     db_id: OCI DB OCID to check port access
#     source_cidr: WLS subnet CIDR
#
# Returns:
#   0|1
####################################################
function validate_ocidb_port_access() {
  local port_found_open=1
  local subnet_id=$1
  local ocidb_id=$2
  local source_cidr=$3

  nsg_list=$(oci db system get --db-system-id ${ocidb_id} | jq -c '.data["nsg-ids"]')

  if [[ $nsg_list != "null" ]]; then
    # Convert to bash array
    declare -A nsg_list_array

    while IFS="=" read -r key value
    do
      nsg_list_array[$key]="$value"
    done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' <<< "$nsg_list")

    # Check the NSG ingress rules for specified destination port is open for access by source CIDR
    for nsg_ocid in "${nsg_list_array[@]}"
    do
      if [[ $port_found_open -ne 0 ]]; then
        port_found_open=$(check_tcp_port_open_in_seclist_or_nsg $nsg_ocid "${DB_PORT}" "$source_cidr" "nsg")
      fi
    done
  fi
  if [[ port_found_open -ne 0 ]]; then
    # If OCI DB port is not opened by NSG ingress rules, check subnet security list
    # doc: "if you choose a subnet with a security list, the security rules for the database
    # will be a union of the rules in the security list and the NSGs."
    port_found_open=$(validate_subnet_port_access ${subnet_id} ${DB_PORT} ${source_cidr})
  fi

  echo $port_found_open
}

####################################################
# Validates if custom resolver has 169.254.169.254 dns entry for WLS subnet.
# Args:
#     subnet_id:    Subnet Id
#
# Returns:
#   0|1
####################################################
function validate_dhcp_options() {
  local subnet_id=$1
  dhcp_id=$(oci network subnet get --subnet-id ${subnet_id} | jq -r '.data["dhcp-options-id"]')
  resolver_type=$(oci network dhcp-options get --dhcp-id ${dhcp_id} | jq -r '.data["options"][1]["server-type"]')

  if [[ $resolver_type == "CustomDnsServer" ]]; then
    dhcp_options=$(oci network dhcp-options get --dhcp-id ${dhcp_id})
    dns_servers=($(jq -r '.data["options"][1]["custom-dns-servers"]|.[]' <<< "$dhcp_options"))
    for dns_server in "${dns_servers[@]}"
    do
      if [[ $dns_server == '169.254.169.254' ]];then
        echo 0
        return
      fi
    done
  else
    echo 0
    return
  fi
  echo 1
}

####################################################
# Validates if VCN is created with "Use DNS hostnames in this VCN"
#
# Args:
#     subnet_id:    Subnet Id
#
# Returns:
#   0|1
####################################################
function validate_vcn_with_dns_hostname_set() {
  local subnet_id=$1

  dns_label=$(oci network subnet get --subnet-id ${subnet_id} | jq -r '.data["dns-label"]')
  if [[ "${dns_label}" == "null" ]];then
    echo 1
  else
    echo 0
  fi
}

####################################################
# Validates if CIDR is a valid single host IP (must end with /32 suffix).
#
# Args:
#     ip_cidr: Single host IPv4 Address in CIDR format
#
# Returns:
#   0|1
####################################################
function is_valid_ip_cidr() {
  local ip_cidr=$1

  is_valid=$(echo ${ip_cidr} | grep -E '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(32))$')
  if [[ -n $is_valid ]]; then
    echo 0
  else
    echo 1
  fi
}

############## Begin Options and Usage ###################

# Print usage
usage() {
  echo -n "$0 [OPTIONS]...

This script is used to validate existing subnets, and optionally network security groups, meet the pre-requisite for provisioning a WebLogic for OCI instance.
 ${bold}Options:${reset}
  -w, --wlssubnet     WebLogic Subnet OCID (Required)
  -p, --http_port     WebLogic Admin Console http port (defaults to 7001)
  -s, --https_port    WebLogic Admin Console https port (defaults to 7002)
  -d, --ocidbid       OCI Database System OCID
  -P, --ocidbport     OCI Database Port
  -t, --atpdbid       ATP Database OCID
  -g, --lpg           OCID of the Local Peering Gateway (LPG) in the DB VCN (Required if WLS VCN LPG is specified)
  -r, --wlslpg        OCID of the Local Peering Gateway (LPG) in the WLS VCN (Required if DB VCN LPG is specified)
  -b, --bastionsubnet Bastion Subnet OCID
  -i, --bastionip     Bastion Host IP. Provide this if using existing bastion
  -j, --lbsourcecidr  Load Balance Source CIDR
  -u, --lbsubnet1     Load Balancer Subnet 1 OCID
  -v, --lbsubnet2     Load Balancer Subnet 2 OCID which is required only for AD subnet
  -l, --externalport  WebLogic Managed Server External Port
  -f, --fsssubnet     File Storage Service (FSS) Mount Target Subnet OCID
  -a, --adminsrvnsg   OCID of the Network Security Group (NSG) for the administration server (Required if using NSGs instead of security lists)
  -m, --managedsrvnsg OCID of the Network Security Group (NSG) for the managed servers (Required if using NSGs instead of security lists)
  -o, --lbnsg         OCID of the Network Security Group (NSG) for the load balancer
  -e, --fssnsg        OCID of the Network Security Group (NSG) for the File Storage Service (FSS) mount target
  -n, --bastionnsg    OCID of the Network Security Group (NSG) for the bastion
      --debug         Runs script in BASH debug mode (set -x)
  -h, --help          Display this help and exit
      --version       Output version information and exit
  "
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; exit 0 ;;
    --version) echo "$(basename $0) ${version}"; exit 0 ;;
    -w|--wlssubnet) shift; WLS_SUBNET_OCID=${1} ;;
    -p|--http_port) shift; ADMIN_HTTP_PORT=${1} ;;
    -s|--https_port) shift; ADMIN_HTTPS_PORT=${1} ;;
    -c|--idcs_port) shift; IDCS_PORT=${1} ;;
    -d|--ocidbid) shift; OCIDB_OCID=${1} ;;
    -P|--ocidbport) shift; DB_PORT=${1} ;;
    -t|--atpdbid) shift; ATPDB_OCID=${1} ;;
    -g|--lpg) shift; LPG_OCID=${1} ;;
    -r|--wlslpg) shift; WLS_LPG_OCID=${1};;
    -b|--bastionsubnet) shift; BASTION_SUBNET_OCID=${1} ;;
    -i|--bastionip) shift; BASTION_HOST_IP=${1} ;;
    -j|--lbsourcecidr) shift; LB_SOURCE_CIDR=${1} ;;
    -u|--lbsubnet1) shift; LB_SUBNET_1_OCID=${1} ;;
    -v|--lbsubnet2) shift; LB_SUBNET_2_OCID=${1} ;;
    -l|--externalport) shift; WLS_LB_PORT=${1} ;;
    -f|--fsssubnet) shift; FSS_SUBNET_OCID=${1} ;;
    -a|--adminsrvnsg) shift; ADMIN_SRV_NSG_OCID=${1} ;;
    -m|--managedsrvnsg) shift; MANAGED_SRV_NSG_OCID=${1} ;;
    -o|--lbnsg) shift; LB_NSG_OCID=${1} ;;
    -e|--fssnsg) shift; FSS_NSG_OCID=${1} ;;
    -n|--bastionnsg) shift; BASTION_NSG_OCID=${1} ;;
    -z|--securemode) shift; SECURE_MODE=${1} ;;
    --debug) debug=true;;
    --endopts) shift; break ;;
    *) "invalid option: '$1'." ; usage >&2; exit 1 ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

############## End Options and Usage ###################

# ############# ############# #############
# ##       MAIN SCRIPT BODY              ##
# ##                                     ##
# ##                                     ##
# ############# ############# #############

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Setting the WLS LB port when IDCS is enabled
if [[ -n ${IDCS_PORT} ]]
then
  WLS_LB_PORT=${IDCS_PORT}
fi

# Convert to lowercase for case insensitive check
secure_mode=$(echo "$SECURE_MODE" | tr '[:upper:]' '[:lower:]')

# Change the default value of ports for secured production mode
if [ "$secure_mode" = "true" ]; then
    if [ "${WLS_LB_PORT}" -eq 7003 ]
    then
      WLS_LB_PORT=7004
    fi

    if [ "${ADMIN_HTTPS_PORT}" -eq 7002 ]
    then
      ADMIN_HTTPS_PORT=9002
    fi

    T3_PORT=9072
fi

### Validate all required params are present ###

# Required for validating existing subnets
if [[ -z ${WLS_SUBNET_OCID} ]]
then
  echo "One or more required params are not specified."
  usage >&2
  exit 1
fi

# Required for validating existing NSGs

# If Admin server NSG is provided then Managed server NSG is required
if [[ -n ${ADMIN_SRV_NSG_OCID} ]]
then
  if [[ -z ${MANAGED_SRV_NSG_OCID} ]]
  then
   echo "One or more required parameters are not specified."
   usage >&2
   exit 1
   fi
fi
# If Managed server NSG is provided then Admin server NSG is required
if [[ -n ${MANAGED_SRV_NSG_OCID} ]]
then
  if [[ -z ${ADMIN_SRV_NSG_OCID} ]]
  then
   echo "One or more required parameters are not specified."
   usage >&2
   exit 1
   fi
fi
# If Load Balancer NSG is provided then Admin server NSG,Managed server NSG & LB subnet are required
if [[ -n ${LB_NSG_OCID} ]]
then
  if [[ -z ${ADMIN_SRV_NSG_OCID} || -z ${MANAGED_SRV_NSG_OCID} || -z ${LB_SUBNET_1_OCID} ]]
  then
   echo "One or more required parameters are not specified."
   usage >&2
   exit 1
   fi
fi
# If  Bastion NSG is provided then Admin server NSG,Managed server NSG & Bastion subnet or Bastion host IP CIDR are required
if [[ -n ${BASTION_NSG_OCID} ]]
then
  if [[ -z ${ADMIN_SRV_NSG_OCID} || -z ${MANAGED_SRV_NSG_OCID} || -z ${BASTION_SUBNET_OCID} || ${BASTION_HOST_IP_CIDR} ]]
  then
   echo "One or more required parameters are not specified."
   usage >&2
   exit 1
   fi
fi
#If DB VCN LPG is provided, then WLS VCN LPG is required.
if [[ -n ${LPG_OCID} ]]
then
  if [[ -z ${WLS_LPG_OCID} ]]
  then
    echo "When --lpg or -g is set then --wlslpg -r must also be set.
    Only the --lpg argument is specified. Add the --wlslpg with the WLS VCN Local Peering Gateway OCID value."
    usage >&2
    exit 1
   fi
fi
#If WLS VCN LPG is provided, then DB VCN LPG is required.
if [[ -n ${WLS_LPG_OCID} ]]
then
  if [[ -z ${LPG_OCID} ]]
  then
    echo "When --lpg or -g is set then --wlslpg -r must also be set.
    Only the --wlslpg argument is specified. Add the --lpg with the Database VCN Local Peering Gateway OCID value."
    usage >&2
    exit 1
   fi
fi

validation_return_code=0

# Check if Service or NAT gateway exists in WLS subnet's VCN.
res=$(validate_service_or_nat_gw_exist)
if [[ $res -eq 1 ]]
then
  echo "ERROR: Missing Service or NAT gateway in the VCN of the private WLS subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
  validation_return_code=2
elif [[ $res -eq 2 ]]
then
  echo "ERROR: Private WLS subnet [$WLS_SUBNET_OCID] does not use NAT or Service gateway. ${NETWORK_VALIDATION_MSG}"
  validation_return_code=2
elif [[ $res -eq 3 ]]
then
  echo "ERROR: Service Gateway in VCN of private WLS subnet [$WLS_SUBNET_OCID] does not allow access to all services in Oracle services network. ${NETWORK_VALIDATION_MSG}"
  validation_return_code=2
elif [[ $res -eq 4 ]]
then
  echo "ERROR: Route Rule of private WLS subnet [$WLS_SUBNET_OCID] does not use 'ALL Services in Oracle services network' destinationi. ${NETWORK_VALIDATION_MSG}"
  validation_return_code=2
fi

# Check for Custom Resolver
res=$(validate_dhcp_options ${WLS_SUBNET_OCID})
if [[ $res -ne 0 ]]
then
  echo "WARNING: Missing OCI DNS Server [169.254.169.254] in the DNS Servers entries for the custom resolver. ${NETWORK_VALIDATION_MSG}"
fi

# Check if Internet Gateway exists in WLS subnet's VCN.
res=$(validate_internet_gw_exist)
if [[ $res -ne 0 ]]
then
  echo "WARNING: Missing internet gateway in the VCN of the WLS subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
fi

#Check if the subnet is created with USE DNS HOSTNAMES IN THIS SUBNET
res=$(validate_vcn_with_dns_hostname_set ${WLS_SUBNET_OCID})
if [[ $res -ne 0 ]]
then
  echo "ERROR: Subnet [$WLS_SUBNET_OCID] needs to be created with the USE DNS HOSTNAMES IN THIS SUBNET enabled."
  validation_return_code=2
fi

### Validation - Only when WLS Subnet OCID is provided ###

if [[ -n ${WLS_SUBNET_OCID} && -z ${ADMIN_SRV_NSG_OCID} && -z ${MANAGED_SRV_NSG_OCID} ]]
then
# Check egress rule to allow all traffic on all ports in WLS Subnet CIDR.
  res=$(validate_egress_rule ${WLS_SUBNET_OCID})

  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -ne 0 ]]
  then
    echo "ERROR: Missing egress rule to allow all traffic on all ports in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
    validation_return_code=2
  fi
  wls_subnet_cidr_block=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["cidr-block"]')

  # Check if SSH port is open for access by WLS subnet CIDR
  res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${SSH_PORT} ${wls_subnet_cidr_block})
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -ne 0 ]]
  then
    echo "ERROR: Port ${SSH_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
    validation_return_code=2
  fi

  # Check if T3 Port is open for access by WLS subnet CIDR
  res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${T3_PORT} ${wls_subnet_cidr_block})
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -ne 0 ]]
  then
    echo "ERROR: Port ${T3_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
    validation_return_code=2
  fi

  # Check if Admin Console HTTP Port is open for access to ALL_IPS by WLS subnet CIDR
  res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${ADMIN_HTTP_PORT} ${ALL_IPS})
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -eq 0 ]]
  then
    echo "WARNING: Exposing the WebLogic administrator port [${ADMIN_HTTP_PORT}] in the subnet [{$WLS_SUBNET_OCID}] to the internet [${ALL_IPS}] allows any user to access the WebLogic console, which is not a recommended practice. Ensure that only a specific CIDR range can access the WebLogic console. ${NETWORK_VALIDATION_MSG}"
  fi

  # Check if Admin Console HTTPS Port is open for access to ALL_IPS by WLS subnet CIDR
  res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${ADMIN_HTTPS_PORT} ${ALL_IPS})
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -eq 0 ]]
  then
    echo "WARNING: Exposing the WebLogic administrator port [${ADMIN_HTTPS_PORT}] in the subnet [{$WLS_SUBNET_OCID}] to the internet [${ALL_IPS}] allows any user to access the WebLogic console, which is not a recommended practice. Ensure that only a specific CIDR range can access the WebLogic console. ${NETWORK_VALIDATION_MSG}"
  fi

  # Check if Administration Port is open for access by WLS subnet CIDR for secure mode
  if [ "$secure_mode" = "true" ]; then
    res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${ADMIN_HTTPS_PORT} ${wls_subnet_cidr_block})
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "ERROR: Port ${ADMIN_HTTPS_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi
  fi
fi

### Validation - Only when WLS Subnet OCID, Admin Server NSG & Managed Server NSG are provided ###

if [[ -n ${WLS_SUBNET_OCID} && -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
then
  # Check egress rule to allow all traffic on all ports in Managed Server NSG.
  res=$(check_egress_all_traffic_in_nsg_or_seclist ${MANAGED_SRV_NSG_OCID} "nsg")
  if [[ $res == *"WARNING"* ]]; then
      for warning in "${res[@]}"; do
          echo "$warning"
      done
  elif [[ $res -ne 0 ]]; then
      echo "ERROR: Missing egress rule to allow traffic on all ports in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
  fi
  # Check if SSH port is open for access by WLS subnet CIDR in Admin Server NSG
  wls_subnet_cidr_block=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["cidr-block"]')
  res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID "${SSH_PORT}" "$wls_subnet_cidr_block" "nsg")
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -ne 0 ]]
  then
    echo "ERROR: Port ${SSH_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
    validation_return_code=2
  fi

  # Check if T3 Port is open for access by WLS subnet CIDR in Managed Server NSG
  res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID "${T3_PORT}" "$wls_subnet_cidr_block" "nsg")
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -ne 0 ]]
  then
    echo "ERROR: Port ${T3_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
    validation_return_code=2
  fi

  # Check if Admin Console HTTP Port is open for access to ALL_IPS by WLS subnet CIDR in Admin Server NSG
  res=$(check_tcp_port_open_in_seclist_or_nsg $ADMIN_SRV_NSG_OCID "${ADMIN_HTTP_PORT}" "$ALL_IPS" "nsg")
  if [[ $res == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -eq 0 ]]
  then
    echo "WARNING: Exposing the WebLogic administrator port [${ADMIN_HTTP_PORT}] in the Admin Server NSG [{$ADMIN_SRV_NSG_OCID}] to the internet [${ALL_IPS}] allows any user to access the WebLogic console, which is not a recommended practice. Ensure that only a specific CIDR range can access the WebLogic console. ${NETWORK_VALIDATION_MSG}"
  fi

  # Check if Admin Console HTTPS Port is open for access to ALL_IPS by WLS subnet CIDR in Admin Server NSG
  res=$(check_tcp_port_open_in_seclist_or_nsg $ADMIN_SRV_NSG_OCID "${ADMIN_HTTPS_PORT}" "$ALL_IPS" "nsg")
  if [[ ${res} == *"WARNING"* ]]
  then
    for warning in "${res[@]}"; do
      echo "$warning"
    done
  elif [[ $res -eq 0 ]]
  then
    echo "WARNING: Exposing the WebLogic administrator port [${ADMIN_HTTPS_PORT}] in the Admin Server NSG [{$ADMIN_SRV_NSG_OCID}] to the internet [${ALL_IPS}] allows any user to access the WebLogic console, which is not a recommended practice. Ensure that only a specific CIDR range can access the WebLogic console. ${NETWORK_VALIDATION_MSG}"
  fi

  # Check if Administration Port is open for access by WLS subnet CIDR in Managed Server NSG for secure mode
  if [ "$secure_mode" = "true" ]; then
    res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID ${ADMIN_HTTPS_PORT} "$wls_subnet_cidr_block" "nsg")
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "ERROR: Port ${ADMIN_HTTPS_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi
  fi
fi

### Validation - Only when OCI DB OCID is provided ###

if [[ -n ${OCIDB_OCID} ]]
then
  ocidb_subnet_ocid=$(oci db system get --db-system-id ${OCIDB_OCID} | jq -r '.data["subnet-id"]')
  ocidb_nsg_ocid=$(oci db system get --db-system-id ${OCIDB_OCID} | jq -c '.data["nsg-ids"]')
  if [[ $ocidb_subnet_ocid != null ]]; then
    # Check if DB port is open for access by WLS subnet CIDR in DB subnet/NSG
    res=$(validate_ocidb_port_access ${ocidb_subnet_ocid} ${OCIDB_OCID} ${wls_subnet_cidr_block})
    if [[ $res -ne 0 ]]; then
      echo "ERROR: DB port ${DB_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in DB Subnet [$ocidb_subnet_ocid] or in DB NSG [$ocidb_nsg_ocid]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi

    # Check if DB subnet has 5 security lists
    sec_lists_count=$(oci network subnet get --subnet-id ${ocidb_subnet_ocid} | jq -c '.data["security-list-ids"] | length')
    if [[ $sec_lists_count -eq 5 && $res -ne 0 ]]
    then
      echo "WARNING: Subnet security list limit reached for the DB subnet [${ocidb_subnet_ocid}]. Five security lists are already associated with it and a new security list cannot be added. Ensure that one of the security rules opens the DB port ${DB_PORT} for WLS Subnet CIDR [$wls_subnet_cidr_block] in DB Subnet [$ocidb_subnet_ocid] or in DB NSG [$ocidb_nsg_ocid]. Also, when creating a stack, do not select the Create Database Security List option. ${NETWORK_VALIDATION_MSG}"
    fi

    # Check if LPG is in OCI DB VCN & WLS LPG is in WLS VCN & peering status is valid
    if [[ -n ${LPG_OCID} && -n ${WLS_LPG_OCID} ]]
    then
      ocidb_vcn_ocid=$(oci network subnet get --subnet-id ${ocidb_subnet_ocid} | jq -r '.data["vcn-id"]')
      lpg_vcn_ocid=$(oci network local-peering-gateway get --local-peering-gateway-id ${LPG_OCID} | jq -r '.data["vcn-id"]')
      if [[ "${lpg_vcn_ocid//\"}" != "${ocidb_vcn_ocid//\"}" ]]; then
        echo "ERROR: LPG [${LPG_OCID}] is not in OCI DB VCN [${ocidb_vcn_ocid}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      wls_vcn_ocid=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["vcn-id"]')
      wls_lpg_vcn_ocid=$(oci network local-peering-gateway get --local-peering-gateway-id ${WLS_LPG_OCID} | jq -r '.data["vcn-id"]')
      if [[ "${wls_lpg_vcn_ocid//\"}" != "${wls_vcn_ocid//\"}" ]]; then
        echo "ERROR: LPG [${WLS_LPG_OCID}] is not in WLS VCN [${wls_vcn_ocid}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      lpg_peering_status=$(oci network local-peering-gateway get --local-peering-gateway-id ${LPG_OCID} | jq -c '.data["peering-status"]')
      if [[ "${lpg_peering_status//\"}" != "PEERED" ]]; then
        echo "ERROR: LPG [${LPG_OCID}] cannot be used to provision a new stack. The peering status is [${lpg_peering_status}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      #Check if the DB Subnet has a Route rule to  WLS CIDR
      vcn_cidr=$(oci network vcn get --vcn-id ${ocidb_vcn_ocid} | jq -r '.data["cidr-block"]')
      res=$(validate_lpg_route_rule ${ocidb_subnet_ocid} ${vcn_cidr})
      if [[ $res -ne 0 ]]; then
        echo "ERROR: Route Rule in the DB Subnet[${ocidb_subnet_ocid}] is not having an entry with LPG for WLS VCN CIDR"
        validation_return_code=2
      fi
      #Check if the WLS Subnet has a Route rule to DB CIDR
      wls_vcn_cidr=$(oci network vcn get --vcn-id ${wls_vcn_ocid} | jq -r '.data["cidr-block"]')
      res=$(validate_lpg_route_rule ${WLS_SUBNET_OCID} ${wls_vcn_cidr})
      if [[ $res -ne 0 ]]; then
        echo "ERROR: Route Rule in the WLS Subnet[${WLS_SUBNET_OCID}] is not having an entry with LPG for DB VCN CIDR"
        validation_return_code=2
      fi
    fi
  fi
  # Check if Egress rule to DB port is present in WLS subnet security list or Managed Server NSG
  db_subnet_cidr_block=$(oci network subnet get --subnet-id ${ocidb_subnet_ocid} | jq -r '.data["cidr-block"]')
  if [[ -n ${MANAGED_SRV_NSG_OCID} ]]; then
    res=$(check_egress_db_traffic_in_nsg_or_seclist ${MANAGED_SRV_NSG_OCID}  "nsg" ${db_subnet_cidr_block} ${DB_PORT})
  else
    res=$(validate_db_egress_rule ${WLS_SUBNET_OCID} ${db_subnet_cidr_block} ${DB_PORT})
  fi

  if [[ $res -ne 0 ]]; then
    echo "ERROR: Egress rule - DB port ${DB_PORT} is not open for access by DB Subnet CIDR [${db_subnet_cidr_block}] in WLS Subnet [${WLS_SUBNET_OCID}] or in WLS NSG [${MANAGED_SRV_NSG_OCID}]."
    validation_return_code=2
  fi
fi

### Validation - Only when ATP DB OCID is provided ###

if [[ -n ${ATPDB_OCID} ]]
then
  atp_subnet_ocid=$(oci db autonomous-database get --autonomous-database-id ${ATPDB_OCID} | jq -r '.data["subnet-id"]')
  atp_nsg_ocid=$(oci db autonomous-database get --autonomous-database-id ${ATPDB_OCID} | jq -c '.data["nsg-ids"]')
  if [[ $atp_subnet_ocid != null ]]; then
    # Check if ATP DB port is open for access by WLS subnet CIDR in DB subnet/NSG
    res=$(validate_atpdb_port_access ${atp_subnet_ocid} ${ATPDB_OCID} ${wls_subnet_cidr_block})
    if [[ $res -ne 0 ]]; then
      echo "ERROR: ATP DB port ${ATP_DB_PORT} is not open for access by WLS Subnet CIDR [$wls_subnet_cidr_block] in ATP DB Subnet [${atp_subnet_ocid}] or in ATP DB NSG [$atp_nsg_ocid]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi

    # Check if LPG is in ATP DB VCN & WLS LPG is in WLS VCN & peering status is valid
    if [[ -n ${LPG_OCID} && -n ${WLS_LPG_OCID} ]]
    then
      atp_vcn_ocid=$(oci network subnet get --subnet-id $atp_subnet_ocid | jq -r '.data["vcn-id"]')
      lpg_vcn_ocid=$(oci network local-peering-gateway get --local-peering-gateway-id ${LPG_OCID} | jq -r '.data["vcn-id"]')
      if [[ "${lpg_vcn_ocid//\"}" != "${atp_vcn_ocid//\"}" ]]; then
        echo "ERROR: LPG [${LPG_OCID}] is not in ATP DB VCN [${atp_vcn_ocid}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      wls_vcn_ocid=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["vcn-id"]')
      wls_lpg_vcn_ocid=$(oci network local-peering-gateway get --local-peering-gateway-id ${WLS_LPG_OCID} | jq -r '.data["vcn-id"]')
      if [[ "${wls_lpg_vcn_ocid//\"}" != "${wls_vcn_ocid//\"}" ]]; then
        echo "ERROR: LPG [${WLS_LPG_OCID}] is not in WLS VCN [${wls_vcn_ocid}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      lpg_peering_status=$(oci network local-peering-gateway get --local-peering-gateway-id ${LPG_OCID} | jq -r '.data["peering-status"]')
      if [[ "${lpg_peering_status//\"}" != "PEERED" ]]; then
        echo "ERROR: LPG [${LPG_OCID}] cannot be used to provision a new stack. The peering status is [${lpg_peering_status}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
      #Check if the DB Subnet has a Route rule to  WLS CIDR
      vcn_cidr=$(oci network vcn get --vcn-id ${atp_vcn_ocid} | jq -r '.data["cidr-block"]')
      res=$(validate_lpg_route_rule ${atp_subnet_ocid} ${vcn_cidr})
      if [[ $res -ne 0 ]]; then
        echo "ERROR: Route Rule in the DB Subnet[${atp_subnet_ocid}] is not having an entry with LPG for WLS VCN CIDR"
        validation_return_code=2
      fi
      #Check if the WLS Subnet has a Route rule to DB CIDR
      wls_vcn_cidr=$(oci network vcn get --vcn-id ${wls_vcn_ocid} | jq -r '.data["cidr-block"]')
      res=$(validate_lpg_route_rule ${WLS_SUBNET_OCID} ${wls_vcn_cidr})
      if [[ $res -ne 0 ]]; then
        echo "ERROR: Route Rule in the WLS Subnet[${WLS_SUBNET_OCID}] is not having an entry with LPG for DB VCN CIDR"
        validation_return_code=2
      fi
    fi
  fi
  # Check if Egress rule to DB port is present in WLS subnet security list or Managed Server NSG
  db_subnet_cidr_block=$(oci network subnet get --subnet-id ${atp_subnet_ocid} | jq -r '.data["cidr-block"]')
  if [[ -n ${MANAGED_SRV_NSG_OCID} ]]; then
    res=$(check_egress_db_traffic_in_nsg_or_seclist ${MANAGED_SRV_NSG_OCID}  "nsg" ${db_subnet_cidr_block} ${ATP_DB_PORT})
  else
    res=$(validate_db_egress_rule ${WLS_SUBNET_OCID} ${db_subnet_cidr_block} ${ATP_DB_PORT})
  fi

  if [[ $res -ne 0 ]]; then
    echo "ERROR: Egress rule - DB port ${DB_PORT} is not open for access by DB Subnet CIDR [${db_subnet_cidr_block}] in WLS Subnet [${WLS_SUBNET_OCID}] or in WLS NSG [${MANAGED_SRV_NSG_OCID}]."
    validation_return_code=2
  fi
fi

### Validation - Only when Bastion subnet/NSG OCID or Bastion Host IP CIDR is provided) ###

# Check if Bastion subnet/NSG has SSH port open for 0.0.0.0/0
if [[ -n ${BASTION_SUBNET_OCID} || -n ${BASTION_HOST_IP} ]]
then
  is_private_subnet=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["prohibit-public-ip-on-vnic"]')

 if [[ $is_private_subnet = true ]]
  then
    if [[ -z ${BASTION_NSG_OCID} ]]
    then
      if [[ -n ${BASTION_SUBNET_OCID} ]]
      then
        res=$(validate_subnet_port_access ${BASTION_SUBNET_OCID} ${SSH_PORT} ${ALL_IPS})
        if [[ $res == *"WARNING"* ]]
        then
          for warning in "${res[@]}"; do
            echo "$warning"
          done
        elif [[ $res -ne 0 ]]
        then
          echo "ERROR: SSH port ${SSH_PORT} is not open for access by [$ALL_IPS] in Bastion Subnet [$BASTION_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
          validation_return_code=2
        fi
     fi
    else
      if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
      then
        res=$(check_tcp_port_open_in_seclist_or_nsg $BASTION_NSG_OCID "${SSH_PORT}" "$ALL_IPS" "nsg")
        if [[ $res == *"WARNING"* ]]
        then
          for warning in "${res[@]}"; do
            echo "$warning"
          done
        elif [[ $res -ne 0 ]]
        then
          echo "ERROR: SSH port ${SSH_PORT} is not open for access by [$ALL_IPS] in Bastion NSG [$BASTION_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
          validation_return_code=2
        fi
      fi
    fi

    # Check if Bastion Host IP is a valid CIDR
    bastion_cidr_block=""
    if [[ -n ${BASTION_HOST_IP} ]]
    then
      BASTION_HOST_IP_CIDR="$BASTION_HOST_IP/32"
      is_valid_cidr=$(is_valid_ip_cidr ${BASTION_HOST_IP_CIDR})
      if [[ $is_valid_cidr -ne 0 ]]
      then
        echo "Bastion host IP CIDR is not valid: [${BASTION_HOST_IP_CIDR}]"
        usage >&2
        exit 1
      fi
      bastion_cidr_block=${BASTION_HOST_IP_CIDR}
    else
      bastion_cidr_block=$(oci network subnet get --subnet-id ${BASTION_SUBNET_OCID} | jq -r '.data["cidr-block"]')
    fi

    # Check if bastion Host IP CIDR or Bastion Subnet CIDR has access to SSH port on WLS subnet or Managed Server NSG
    if [[ -z ${ADMIN_SRV_NSG_OCID} && -z ${MANAGED_SRV_NSG_OCID} ]]
    then
      res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${SSH_PORT} ${bastion_cidr_block})
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "WARNING: SSH port ${SSH_PORT} is not open for access by [$bastion_cidr_block] in private WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
      fi
    else
      if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
      then
        res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID "${SSH_PORT}" "$bastion_cidr_block" "nsg")
        if [[ $res == *"WARNING"* ]]
        then
          for warning in "${res[@]}"; do
            echo "$warning"
          done
        elif [[ $res -ne 0 ]]
        then
          echo "WARNING: SSH port ${SSH_PORT} is not open for access by [$bastion_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
        fi
      fi
    fi

    # In secured production mode, Check if bastion Host IP CIDR or Bastion Subnet CIDR has access to Administration Port on WLS subnet or Admin Server NSG
    if [ "$secure_mode" = "true" ]; then
      if [[ -z ${ADMIN_SRV_NSG_OCID} && -z ${MANAGED_SRV_NSG_OCID} ]]
      then
        res=$(validate_subnet_port_access ${WLS_SUBNET_OCID} ${ADMIN_HTTPS_PORT} ${bastion_cidr_block})
        if [[ $res == *"WARNING"* ]]
        then
          for warning in "${res[@]}"; do
            echo "$warning"
          done
        elif [[ $res -ne 0 ]]
        then
          echo "ERROR: Port ${ADMIN_HTTPS_PORT} is not open for access by [$bastion_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
          validation_return_code=2
        fi
      fi

      if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
      then
        res=$(check_tcp_port_open_in_seclist_or_nsg $ADMIN_SRV_NSG_OCID ${ADMIN_HTTPS_PORT} ${bastion_cidr_block} "nsg")
        if [[ $res == *"WARNING"* ]]
        then
          for warning in "${res[@]}"; do
            echo "$warning"
          done
        elif [[ $res -ne 0 ]]
        then
          echo "ERROR: Port ${ADMIN_HTTPS_PORT} is not open for access by [$bastion_cidr_block] in Admin Server NSG [$ADMIN_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
          validation_return_code=2
        fi
      fi
    fi
  fi
fi

### Validation - Only when LB subnet 1/NSG OCID is provided) ###

# Check if 7003 port is open for access by LB Subnet in WLS Subnet/Managed Server NSG
if [[ -n ${LB_SUBNET_1_OCID} ]]
then
  lbsubnet_cidr_block=$(oci network subnet get --subnet-id "${LB_SUBNET_1_OCID}" | jq -r '.data["cidr-block"]')
  if [[ -z ${LB_NSG_OCID} ]]
  then
    res=$(validate_subnet_port_access "${WLS_SUBNET_OCID}" ${WLS_LB_PORT} "${lbsubnet_cidr_block}")
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "ERROR: LB port ${WLS_LB_PORT} is not open for access by LB Subnet CIDR - [$lbsubnet_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi
  else
    if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
    then
      res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID "${WLS_LB_PORT}" "$lbsubnet_cidr_block" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: LB port ${WLS_LB_PORT} is not open for access by LB Subnet CIDR - [$lbsubnet_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  fi
fi
# Check if LB Subnet port 443 is open in LB Subnet/NSG
if [[ -n ${LB_SUBNET_1_OCID} ]]
then
  if [[ -z ${LB_NSG_OCID} ]]
  then
    res=$(validate_subnet_port_access "${LB_SUBNET_1_OCID}" ${LB_PORT} "${LB_SOURCE_CIDR}")
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "WARNING : Port [$LB_PORT] is not open for ${LB_SOURCE_CIDR} in LB Subnet CIDR [${LB_SUBNET_1_OCID}]. ${NETWORK_VALIDATION_MSG}"
    fi
  else
    if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
    then
      res=$(check_tcp_port_open_in_seclist_or_nsg $LB_NSG_OCID "${LB_PORT}" "${LB_SOURCE_CIDR}" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "WARNING : Port [$LB_PORT] is not open for ${LB_SOURCE_CIDR} in Load Balancer Server NSG [${LB_NSG_OCID}]. ${NETWORK_VALIDATION_MSG}"
      fi
    fi
  fi
fi

### Validation - Only when LB subnet 2/NSG OCID is provided) ###

# Check if 7003 port is open for access by LB Subnet 2 in WLS Subnet/Managed Server NSG
if [[ -n ${LB_SUBNET_2_OCID} ]]
then
  lbsubnet2_cidr_block=$(oci network subnet get --subnet-id "${LB_SUBNET_2_OCID}" | jq -r '.data["cidr-block"]')
  if [[ -z ${LB_NSG_OCID} ]]
  then
    res=$(validate_subnet_port_access "${WLS_SUBNET_OCID}" ${WLS_LB_PORT} "${lbsubnet2_cidr_block}")
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "ERROR: LB port ${WLS_LB_PORT} is not open for access by LB Subnet CIDR - [$lbsubnet2_cidr_block] in WLS Subnet [$WLS_SUBNET_OCID]. ${NETWORK_VALIDATION_MSG}"
      validation_return_code=2
    fi
  else
    if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
    then
      res=$(check_tcp_port_open_in_seclist_or_nsg $MANAGED_SRV_NSG_OCID "${WLS_LB_PORT}" "$lbsubnet2_cidr_block" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: LB port ${WLS_LB_PORT} is not open for access by LB Subnet CIDR - [$lbsubnet2_cidr_block] in Managed Server NSG [$MANAGED_SRV_NSG_OCID]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  fi
fi

# Check if LB Subnet port 443 is open in LB Subnet/NSG
if [[ -n ${LB_SUBNET_2_OCID} ]]
then
  if [[ -z ${LB_NSG_OCID} ]]
  then
    res=$(validate_subnet_port_access "${LB_SUBNET_2_OCID}" ${LB_PORT} "${LB_SOURCE_CIDR}")
    if [[ $res == *"WARNING"* ]]
    then
      for warning in "${res[@]}"; do
        echo "$warning"
      done
    elif [[ $res -ne 0 ]]
    then
      echo "WARNING: Port [$LB_PORT] is not open for ${LB_SOURCE_CIDR} in LB Subnet CIDR [${LB_SUBNET_2_OCID}]. ${NETWORK_VALIDATION_MSG}"
    fi
  else
    if [[ -n ${ADMIN_SRV_NSG_OCID} && -n ${MANAGED_SRV_NSG_OCID} ]]
    then
      res=$(check_tcp_port_open_in_seclist_or_nsg $LB_NSG_OCID "${LB_PORT}" "${LB_SOURCE_CIDR}" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "WARNING: Port [$LB_PORT] is not open for ${LB_SOURCE_CIDR} in Load Balancer Server NSG [${LB_NSG_OCID}]. ${NETWORK_VALIDATION_MSG}"
      fi
    fi
  fi
fi

### Validate Mount Target subnet/NSG (only when Mount Target subnet/NSG OCID is provided) ###
# Check TCP Ports - '111' '2048' '2049' '2050' are open in Mount Target SUBNET/NSG for VCN CIDR
if [[ -n ${FSS_SUBNET_OCID} && -z ${FSS_NSG_OCID} ]]
then
  vcn_ocid=$(oci network subnet get --subnet-id "${WLS_SUBNET_OCID}" | jq -r '.data["vcn-id"]')
  vcn_cidr=$(oci network vcn get --vcn-id "${vcn_ocid}" | jq -r '.data["cidr-block"]')

  for port in '111' '2048' '2049' '2050'; do
    if [[ -n ${FSS_SUBNET_OCID} ]]
    then
      res=$(validate_subnet_port_access "${FSS_SUBNET_OCID}" "${port}" "${vcn_cidr}")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: TCP Port [${port}] is not open in FSS Subnet [${FSS_SUBNET_OCID}] for VCN CIDR [${vcn_cidr}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  done

  # Check UDP Ports - '111' '2048' are open in Mount Target SUBNET/NSG for VCN CIDR
  for port in '111' '2048'; do
    if [[ -n ${FSS_SUBNET_OCID} ]]
    then
      res=$(validate_subnet_port_access "${FSS_SUBNET_OCID}" "${port}" "${vcn_cidr}" "UDP")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: UDP Port [${port}] is not open in FSS Subnet [${FSS_SUBNET_OCID}] for VCN CIDR [${vcn_cidr}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  done
fi

# Check TCP Ports - '111' '2048' '2049' '2050' are open in Mount Target SUBNET/NSG for VCN CIDR
if [[ -n ${FSS_NSG_OCID} ]]
then
  vcn_ocid=$(oci network subnet get --subnet-id "${WLS_SUBNET_OCID}" | jq -r '.data["vcn-id"]')
  vcn_cidr=$(oci network vcn get --vcn-id "${vcn_ocid}" | jq -r '.data["cidr-block"]')

  for port in '111' '2048' '2049' '2050'; do
    if [[ -n ${FSS_NSG_OCID} ]]
    then
      res=$(check_tcp_port_open_in_seclist_or_nsg $FSS_NSG_OCID "${port}" "$vcn_cidr" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: TCP Port [${port}] is not open in FSS NSG [${FSS_NSG_OCID}] for VCN CIDR [${vcn_cidr}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  done

  # Check UDP Ports - '111' '2048' are open in Mount Target SUBNET/NSG for VCN CIDR
  for port in '111' '2048'; do
    if [[ -n ${FSS_NSG_OCID} ]]
    then
      res=$(check_udp_port_open_in_seclist_or_nsg $FSS_NSG_OCID "${port}" "$vcn_cidr" "nsg")
      if [[ $res == *"WARNING"* ]]
      then
        for warning in "${res[@]}"; do
          echo "$warning"
        done
      elif [[ $res -ne 0 ]]
      then
        echo "ERROR: UDP Port [${port}] is not open in FSS NSG [${FSS_NSG_OCID}] for VCN CIDR [${vcn_cidr}]. ${NETWORK_VALIDATION_MSG}"
        validation_return_code=2
      fi
    fi
  done
fi

exit ${validation_return_code}
