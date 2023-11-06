#!/bin/bash

terraform -chdir=./proxy init
terraform -chdir=./proxy apply -auto-approve
terraform -chdir=./etcd init
terraform -chdir=./etcd apply -auto-approve
terraform -chdir=./control-plane init
terraform -chdir=./control-plane apply -auto-approve
terraform -chdir=./agent init
terraform -chdir=./agent apply -auto-approve
