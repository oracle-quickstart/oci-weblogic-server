#!/usr/bin/env bash
#
# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ############################################################################
# This script is to create Network Security Groups (NSGs) in existing subnets.
# ############################################################################
#

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
DB_PORT=1521
MS_HTTP_PORT=7003
MS_HTTPS_PORT=7004
LB_PORT=443
CLOUDGATE_PORT=9999
WLS_SUBNET_OCID=""
DB_SUBNET_OCID=""
BASTION_SUBNET_OCID=""
BASTION_HOST_IP_CIDR=""
LB_SUBNET_OCID=""
LB_SUBNET2_OCID=""
MNT_SUBNET_OCID=""

debug=false
args=()

# Function to create NSG
function create_nsg() {
  local vcn_ocid=""
  local vcn_cidr=""
  local vcn_compartment_ocid=""

  vcn_ocid=$(oci network subnet get --subnet-id "${WLS_SUBNET_OCID}" | jq -r '.data["vcn-id"]')
  vcn_cidr=$(oci network vcn get --vcn-id "${vcn_ocid}" | jq -r '.data["cidr-block"]')
  vcn_compartment_ocid=$(oci network vcn get --vcn-id ${vcn_ocid} | jq -r '.data["compartment-id"]')

  network_security_group=$(oci network nsg create \
        --compartment-id $vcn_compartment_ocid \
        --display-name $1 \
        --vcn-id $vcn_ocid \
        --wait-for-state "AVAILABLE" 2> /dev/null \
        | jq -rc '.data')

  network_security_group_ocid=$(echo "${network_security_group}" | jq -r '.id')

  if [[ -n $network_security_group_ocid ]]; then
    echo $network_security_group_ocid
  else
    echo 0
  fi
}

############## Begin Options and Usage ###################

# Print usage
usage() {
  echo -n "$0 [OPTIONS]...

This script is to create Network Security Groups (NSGs) in existing subnets.
 ${bold}Options:${reset}
  -w, --wlssubnet     WebLogic Subnet OCID (Required)
  -d, --dbsubnet      DB Subnet OCID
  -b, --bastionsubnet Bastion Subnet OCID
  -i, --bastionipcidr Bastion Host IP CIDR (should be suffixed with /32)
  -l, --lbsubnet      LB Subnet OCID
  -a, --lbsubnet2     LB Subnet2 OCID (if AD subnet)
  -c, --cloudgateport Cloudgate Port (if IDCS is to be enabled)
  -f, --mntsubnet     Mount Target Subnet OCID
      --debug         Runs script in BASH debug mode (set -x)
  -h, --help          Display this help and exit
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
    -w|--wlssubnet) shift; WLS_SUBNET_OCID=${1} ;;
    -d|--dbsubnet) shift; DB_SUBNET_OCID=${1} ;;
    -b|--bastionsubnet) shift; BASTION_SUBNET_OCID=${1} ;;
    -i|--bastionipcidr) shift; BASTION_HOST_IP_CIDR=${1} ;;
    -l|--lbsubnet) shift; LB_SUBNET_OCID=${1} ;;
    -c|--cloudgateport) shift; CLOUDGATE_PORT=${1} ;;
    -a|--lbsubnet2) shift; LB_SUBNET2_OCID=${1} ;;
    -f|--mntsubnet) shift; MNT_SUBNET_OCID=${1} ;;
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

# Validate all required params are present
if [[ -z ${WLS_SUBNET_OCID} ]]
then
  echo "One or more required params are not specified."
  usage >&2
  exit
fi

# The NSGs will be created in the VCN of the weblogic subnet & in the same compartment as the VCN
vcn_ocid=$(oci network subnet get --subnet-id "${WLS_SUBNET_OCID}" | jq -r '.data["vcn-id"]')
vcn_cidr=$(oci network vcn get --vcn-id "${vcn_ocid}" | jq -r '.data["cidr-block"]')
wls_subnet_cidr_block=$(oci network subnet get --subnet-id ${WLS_SUBNET_OCID} | jq -r '.data["cidr-block"]')

# Create admin & managed server NSGs when weblogic subnet is provided
admin_server_nsg_ocid=""
managed_server_nsg_ocid=""
if [[ -n ${WLS_SUBNET_OCID} ]]
then
  # Create security rules for WLS VM-VM access
  INTERNAL_RULES_FILE=$(mktemp)
  cat > ${INTERNAL_RULES_FILE} << EOF
  [{
  		"description": "TCP traffic for ports: All",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"sourceType": "CIDR_BLOCK",
      "source": "$wls_subnet_cidr_block"
  	},
  	{
  		"description": "All traffic for all ports",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "all",
  		"sourceType": "CIDR_BLOCK",
      "destination": "0.0.0.0/0"
  	}]
EOF
  # Admin Server NSG
  network_security_group_name="admin_server_nsg"
  admin_server_nsg_ocid=$(create_nsg $network_security_group_name)
  if [[ -n $admin_server_nsg_ocid ]]
  then
    echo -e "Created Admin Server Network Security Group: ${admin_server_nsg_ocid}"
  fi

  # Managed server NSG
  network_security_group_name="managed_server_nsg"
  managed_server_nsg_ocid=$(create_nsg $network_security_group_name)
  if [[ -n $managed_server_nsg_ocid ]]
  then
    echo -e "Created Managed Server Network Security Group: ${managed_server_nsg_ocid}"
    echo -e "Adding Security Rules for WLS VM-VM access in the Managed Server Network Security Group $managed_server_nsg_ocid..."
    oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$INTERNAL_RULES_FILE
  fi
fi

# Create bastion server NSG when bastion subnet is provided
bastion_nsg_ocid=""
if [[ -n ${BASTION_SUBNET_OCID} ]]
then
  bastion_cidr_block=$(oci network subnet get --subnet-id ${BASTION_SUBNET_OCID} | jq -r '.data["cidr-block"]')
  # Create security rules for Bastion
  BASTION_RULES_FILE=$(mktemp)
  cat > ${BASTION_RULES_FILE} << EOF
  [{
  		"description": "TCP traffic for ports: 22 SSH Remote Login Protocol",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"source": "0.0.0.0/0",
  		"sourceType": "CIDR_BLOCK",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "22",
  				"max": "22"
  			}
  		}
  	},
  	{
  		"description": "All traffic for all ports",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "all",
  		"sourceType": "CIDR_BLOCK",
      "destination": "0.0.0.0/0"
  	}]
EOF
  # Create security rules for WLS private subnet
  WLS_BASTION_RULES_FILE=$(mktemp)
  cat > ${WLS_BASTION_RULES_FILE} << EOF
  [{
  		"description": "All traffic for all ports",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "all",
      "sourceType": "CIDR_BLOCK",
      "source": "$bastion_cidr_block"
  	}]
EOF

  # Bastion instance NSG
  network_security_group_name="bastion_nsg"
  bastion_nsg_ocid=$(create_nsg $network_security_group_name)
  if [[ -n $bastion_nsg_ocid ]]
  then
    echo -e "Created Bastion Instance Network Security Group: ${bastion_nsg_ocid}"
    echo -e "Adding Security Rules in Bastion Instance Network Security Group $bastion_nsg_ocid..."
    oci network nsg rules add --nsg-id $bastion_nsg_ocid --security-rules file://$BASTION_RULES_FILE
    if [[ -n $managed_server_nsg_ocid ]]
    then
      echo -e "Adding Bastion Security Rules in Managed Server Network Security Group $managed_server_nsg_ocid..."
      oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$WLS_BASTION_RULES_FILE
    fi
  fi
fi

if [[ -n ${BASTION_HOST_IP_CIDR} ]]
then
  # Create security rules for WLS private subnet with existing bastion instance
  WLS_EXT_BASTION_RULES_FILE=$(mktemp)
  cat > ${WLS_EXT_BASTION_RULES_FILE} << EOF
  [{
  		"description": "All traffic for all ports",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "all",
      "sourceType": "CIDR_BLOCK",
      "source": "$BASTION_HOST_IP_CIDR"
  	}]
EOF
  if [[ -n $managed_server_nsg_ocid ]]
  then
    echo -e "Adding Existing Bastion Security Rule in Managed Server Network Security Group $managed_server_nsg_ocid..."
    oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$WLS_EXT_BASTION_RULES_FILE
  fi
fi

# Create load balancer NSG when load balancer subnet is provided
load_balancer_nsg_ocid=""
if [[ -n ${LB_SUBNET_OCID} ]]
then
  lbsubnet_cidr_block=$(oci network subnet get --subnet-id "${LB_SUBNET_OCID}" | jq -r '.data["cidr-block"]')
  lbsubnet_availability_domain=$(oci network subnet get --subnet-id "${LB_SUBNET_OCID}" | jq -r '.data["availability-domain"]')
  is_private_lb=$(oci network subnet get --subnet-id ${LB_SUBNET_OCID} | jq -r '.data["prohibit-public-ip-on-vnic"]')
  lb_source_cidr=0.0.0.0/0

  if [[ $is_private_lb = true && -n ${BASTION_SUBNET_OCID} ]]
  then
    bastion_cidr_block=$(oci network subnet get --subnet-id ${BASTION_SUBNET_OCID} | jq -r '.data["cidr-block"]')
    lb_source_cidr=$bastion_cidr_block
  fi
  # Create security rules for LB
  LB_RULES_FILE=$(mktemp)
  cat > ${LB_RULES_FILE} << EOF
  [{
  		"description": "TCP traffic for ports: 443 HTTPS",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"source": "$lb_source_cidr",
  		"sourceType": "CIDR_BLOCK",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "$LB_PORT",
  				"max": "$LB_PORT"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: All",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "all",
  		"sourceType": "CIDR_BLOCK",
      "destination": "0.0.0.0/0"
  	}]
EOF
  # Create security rules for WLS Managed servers
  WLS_MS_RULES_FILE=$(mktemp)
  cat > ${WLS_MS_RULES_FILE} << EOF
  [{
      "description": "TCP traffic for HTTP port for applications",
      "direction": "INGRESS",
      "isStateless": "false",
      "protocol": "6",
      "sourceType": "CIDR_BLOCK",
      "source": "$lbsubnet_cidr_block",
      "tcpOptions": {
        "destinationPortRange": {
          "min": "$MS_HTTP_PORT",
          "max": "$MS_HTTP_PORT"
        }
      }
    },
    {
      "description": "TCP traffic for HTTPS port for applications",
      "direction": "INGRESS",
      "isStateless": "false",
      "protocol": "6",
      "sourceType": "CIDR_BLOCK",
      "source": "$lbsubnet_cidr_block",
      "tcpOptions": {
        "destinationPortRange": {
          "min": "$MS_HTTPS_PORT",
          "max": "$MS_HTTPS_PORT"
        }
      }
    }]
EOF

  # Create security rule for IDCS - Open CLOUDGATE GATE PORT from LB subnet in MANAGED SERVER NSG
  if [[ -n ${CLOUDGATE_PORT} ]]
  then
    IDCS_RULES_FILE=$(mktemp)
    cat > ${IDCS_RULES_FILE} << EOF
    [{
    		"description": "TCP traffic for cloudgate port",
    		"direction": "INGRESS",
    		"isStateless": "false",
    		"protocol": "6",
    		"sourceType": "CIDR_BLOCK",
    		"source": "$lbsubnet_cidr_block",
    		"tcpOptions": {
    			"destinationPortRange": {
    				"min": "$CLOUDGATE_PORT",
    				"max": "$CLOUDGATE_PORT"
    			}
    		}
    	}]
EOF
  fi

  # Load Balancer NSG
  network_security_group_name="load_balancer_nsg"
  load_balancer_nsg_ocid=$(create_nsg $network_security_group_name)
  if [[ -n $load_balancer_nsg_ocid ]]
  then
    echo -e "Created Load Balancer Network Security Group: ${load_balancer_nsg_ocid}"
    if [[ (($is_private_lb = true && -n ${BASTION_SUBNET_OCID}) || $is_private_lb = false) ]]
    then
      echo -e "Adding LB Security Rules in Load Balancer Network Security Group $load_balancer_nsg_ocid..."
      oci network nsg rules add --nsg-id $load_balancer_nsg_ocid --security-rules file://$LB_RULES_FILE
    fi
    if [[ -n $managed_server_nsg_ocid ]]
    then
      echo -e "Adding LB Security Rules to access MS HTTP port in Managed Server Network Security Group $managed_server_nsg_ocid..."
      oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$WLS_MS_RULES_FILE
      echo -e "Adding IDCS Security Rule to access CLOUD GATE port in Managed Server Network Security Group $managed_server_nsg_ocid..."
      oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$IDCS_RULES_FILE
      if [[ -n $lbsubnet_availability_domain  && $is_private_lb = false ]]
          then
            if [[ -n ${LB_SUBNET2_OCID} ]]
            then
              lbsubnet2_cidr_block=$(oci network subnet get --subnet-id "${LB_SUBNET2_OCID}" | jq -r '.data["cidr-block"]')
              # Create security rules for LB for AD subnet
              WLS_MS_RULES_FILE2=$(mktemp)
                  cat > ${WLS_MS_RULES_FILE2} << EOF
                  [{
                  		"description": "TCP traffic for HTTP port for applications",
                  		"direction": "INGRESS",
                  		"isStateless": "false",
                  		"protocol": "6",
                  		"sourceType": "CIDR_BLOCK",
                  		"source": "$lbsubnet2_cidr_block",
                  		"tcpOptions": {
                  			"destinationPortRange": {
                  				"min": "$MS_HTTP_PORT",
                  				"max": "$MS_HTTP_PORT"
                  			}
                  		}
                  	},
                  	{
                  		"description": "TCP traffic for HTTPS port for applications",
                  		"direction": "INGRESS",
                  		"isStateless": "false",
                  		"protocol": "6",
                  		"sourceType": "CIDR_BLOCK",
                  		"source": "$lbsubnet2_cidr_block",
                  		"tcpOptions": {
                  			"destinationPortRange": {
                  				"min": "$MS_HTTPS_PORT",
                  				"max": "$MS_HTTPS_PORT"
                  			}
                  		}
                  	}]
EOF
              echo -e "Adding LB Security Rules to access MS HTTP port for AD subnet in Admin Server Network Security Group $admin_server_nsg_ocid..."
              oci network nsg rules add --nsg-id $admin_server_nsg_ocid --security-rules file://$WLS_MS_RULES_FILE2
            fi
        fi
    fi
  fi
fi

# Create mount target NSG when mount target subnet is provided
# Security rules for FSS - Open All TCP Ports in MOUNT TARGET SUBNET OCID for VCN CIDR
mount_target_nsg_ocid=""
if [[ -n ${MNT_SUBNET_OCID} ]]
then
  FSS_RULES_FILE=$(mktemp)
  cat > ${FSS_RULES_FILE} << EOF
  [{
  		"description": "TCP traffic for ports: 2048-2050",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"sourceType": "CIDR_BLOCK",
  		"source": "$vcn_cidr",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "2048",
  				"max": "2050"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: 111",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"sourceType": "CIDR_BLOCK",
  		"source": "$vcn_cidr",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "111",
  				"max": "111"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: 111",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "17",
  		"sourceType": "CIDR_BLOCK",
  		"source": "$vcn_cidr",
  		"udpOptions": {
  			"destinationPortRange": {
  				"min": "111",
  				"max": "111"
  			}
  		}
  	},
  	{
  		"description": "UDP traffic for ports: 2048",
  		"direction": "INGRESS",
  		"isStateless": "false",
  		"protocol": "17",
  		"sourceType": "CIDR_BLOCK",
  		"source": "$vcn_cidr",
  		"udpOptions": {
  			"destinationPortRange": {
  				"min": "2048",
  				"max": "2048"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: All",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"destinationType": "CIDR_BLOCK",
  		"destination": "$vcn_cidr",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "2048",
  				"max": "2050"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: All",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"destinationType": "CIDR_BLOCK",
  		"destination": "$vcn_cidr",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "111",
  				"max": "111"
  			}
  		}
  	},
  	{
  		"description": "TCP traffic for ports: All",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "17",
  		"destinationType": "CIDR_BLOCK",
  		"destination": "$vcn_cidr",
  		"udpOptions": {
  			"destinationPortRange": {
  				"min": "111",
  				"max": "111"
  			}
  		}
  	}]
EOF

  # Mount Target NSG
  network_security_group_name="mount_target_nsg"
  mount_target_nsg_ocid=$(create_nsg $network_security_group_name)
  if [[ -n $mount_target_nsg_ocid ]]
  then
    echo -e "Created Mount Target Network Security Group: ${mount_target_nsg_ocid}"
    echo -e "Adding FSS Security Rules in Mount Target Network Security Group $mount_target_nsg_ocid..."
    oci network nsg rules add --nsg-id $mount_target_nsg_ocid --security-rules file://$FSS_RULES_FILE
  fi
fi

# Allow outbound tcp traffic on DB Port when DB subnet is provided
if [[ -n ${DB_SUBNET_OCID} ]]
then
  db_subnet_cidr_block=$(oci network subnet get --subnet-id ${DB_SUBNET_OCID} | jq -r '.data["cidr-block"]')
  DB_RULES_FILE=$(mktemp)
  cat > ${DB_RULES_FILE} << EOF
  [{
  		"description": "TCP traffic for DB port",
  		"direction": "EGRESS",
  		"isStateless": "false",
  		"protocol": "6",
  		"destinationType": "CIDR_BLOCK",
  		"destination": "$db_subnet_cidr_block",
  		"tcpOptions": {
  			"destinationPortRange": {
  				"min": "$DB_PORT",
  				"max": "$DB_PORT"
  		}
  	}
  }]
EOF
  if [[ -n $managed_server_nsg_ocid ]]
  then
    echo -e "Adding Security Rules to allow outbound tcp traffic on DB Port in Managed Server Network Security Group $managed_server_nsg_ocid..."
    oci network nsg rules add --nsg-id $managed_server_nsg_ocid --security-rules file://$DB_RULES_FILE
  fi
fi

# The list of NSGs created by the script
echo -e "The Network Security Groups created are:"
if [[ -n $admin_server_nsg_ocid ]]
  then
    echo -e "Admin Server Network Security Group     : $admin_server_nsg_ocid"
fi
if [[ -n $managed_server_nsg_ocid ]]
  then
    echo -e "Managed Server Network Security Group   : $managed_server_nsg_ocid"
fi
if [[ -n $bastion_nsg_ocid ]]
  then
    echo -e "Bastion Instance Network Security Group : $bastion_nsg_ocid"
fi
if [[ -n $load_balancer_nsg_ocid ]]
  then
    echo -e "Load Balancer Network Security Group    : $load_balancer_nsg_ocid"
fi
if [[ -n $mount_target_nsg_ocid ]]
  then
    echo -e "Mount Target Network Security Group     : $mount_target_nsg_ocid"
fi






