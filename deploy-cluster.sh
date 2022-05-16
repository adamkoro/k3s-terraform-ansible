#!/bin/bash
set -o errexit
set -o pipefail

terraform_install()
{
    if [ ! -f /usr/bin/terraform ]; then
        echo -e "Terraform not found\nPlease install it and run the script again!"
        exit 1
    fi
    cd terraform
    if [ ! -d .terraform ]; then
        terraform init
    fi
    terraform plan
    terraform apply "-auto-approve"
    cd ../
    ansible-playbook ansible/prod-site.yml -i ansible/inventory/prod/hosts.ini
    exit 0
}

cluster_install_full()
{
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini
    exit 0
}

cluster_install(){
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --skip-tags "preparation,partitioning,package_install,database_install"
    exit 0
}

cluster_install_only()
{
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --skip-tags "preparation,partitioning,package_install,database_install,database_update"
    exit 0
}

database_install(){
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --tags "database_install"
    exit 0
}

update_manifests()
{
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --tags "manifests"
    exit 0
}

update_cluster(){
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --tags "cluster_update,manifests"
    exit 0
}

update_database()
{
    ansible-playbook ansible/${CLUSTER_NAME}-site.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --skip-tags "database_update"
    exit 0
}


Help()
{
    echo "Manager script for kubernetes clusters -- Deploy | Updates only"
    echo
    echo "Usage: (--cluster | -c CLUSTER_NAME) (--playbook | -p PLAYBOOK_NAME)"
    echo "Example: bash deploy-cluster.sh --cluster mgmt --playbook update-manifests"
    echo
    echo "Options:"
    echo "  --help,-h                   Print help message"
    echo "  --cluster,-c                Set name of your custer to run the correct Ansible CLUSTER_NAME-site.yml"
    echo "  --playbook,-p               Set name of your playbook to run the correct Ansible playbook"
    echo
    echo "Playbook types:"
    echo "  terraform-install           Cluster install with Terraform"
    echo "  cluster-install-full        Installing the whole cluster with all Ansible roles"
    echo "  cluster-install             Installing the cluster without preparation,partitioning and package_install tags"
    echo "  cluster-install-only        Installing the cluster without "
    echo "  database-install"
    echo "  update-manifests"
    echo "  update-cluster"
    echo "  update-database"
}

# Checks
if [ ! -f /usr/bin/ansible ]; then
    echo -e "Ansible not found\nPlease install it and run the script again!"
    exit 1
fi

if [ -z $1 ];then
    echo -e "ERROR: Parameters are missing\n"
    Help
    exit 1
fi

if [ ${1} == "--help" ] || [ ${1} == "-h" ];then
    echo
else
    if [ $# -ne 4 ]; then
        echo "ERROR: Script parameters are missing!"
        echo -e "\nYou have to specify --cluster CLUSTER_NAME --playbook PLAYBOOK_NAME!"
        echo "Use --help | -h for help"
        exit 1
    fi
fi

while true ; do
    case ${1} in 
        --cluster | -c)
            shift
            CLUSTER_NAME=${1}
        ;;
        --playbook | -p)
            shift
            PLAYBOOK_NAME=${1}
            case ${1} in
                terraform-install)
                    terraform_install
                    ;;
                cluster-install-full)
                    cluster_install_full
                ;;
                cluster-install)
                    cluster_install
                ;;
                cluster-install-only)
                    cluster_install_only
                ;;
                database-install)
                    database_install
                ;;
                update-manifests)
                    update_manifests
                ;;
                update-cluster)
                    update_cluster
                ;;
                update-database)
                    update_database
                ;;
                *)
                    echo "ERROR: ${1} parameter not found!"
                    echo -e "\nInvalid parameter for --playbook | -p!"
                    echo "Use --help | -h for help"
                    exit 1
                ;;
            esac
        ;;
        --help | -h)
            shift
            Help
        ;;
    esac
shift
done