#!/bin/bash
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

echo "Adding keys" >> /tmp/init.log

cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${pubKey}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

echo "Added keys to auth keys" >> /tmp/init.log