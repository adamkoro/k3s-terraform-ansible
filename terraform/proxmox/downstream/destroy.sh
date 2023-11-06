#!/bin/bash

terraform -chdir=./proxy destroy -auto-approve
terraform -chdir=./etcd destroy -auto-approve
terraform -chdir=./control-plane destroy -auto-approve
terraform -chdir=./agent destroy -auto-approve