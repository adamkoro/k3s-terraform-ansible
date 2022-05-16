#!/bin/bash
set -o errexit
set -o pipefail

terraform_remove()
{
    if [ ! -f /usr/bin/terraform ]; then
        echo -e "Terraform not found\nPlease install it and run the script again!"
        exit 1
    fi
    cd terraform
    terraform destroy -auto-approve
    cd ../
    exit 0
}

cluster_remove()
{
    ansible-playbook ansible/${CLUSTER_NAME}-reset.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --become
    exit 0
}

cluster_remove_only()
{
    ansible-playbook ansible/${CLUSTER_NAME}-reset.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --become --skip-tags "partitioning"
    exit 0

}

database_remove(){
    ansible-playbook ansible/${CLUSTER_NAME}-reset.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --become --tags "delete_table"
    exit 0
}

wipe_disks()
{
    ansible-playbook ansible/${CLUSTER_NAME}-reset.yml -i ansible/inventory/${CLUSTER_NAME}/hosts.ini --become --tags "partitioning"
    exit 0
}

Help()
{
    echo "Manage kubernetes clusters"
    echo
    echo "Usage: (--cluster | -c CLUSTER_NAME) (--playbook | -p PLAYBOOK_NAME)"
    echo "Example: bash deploy-cluster.sh --cluster mgmt --playbook update-manifests"
    echo
    echo "Options:"
    echo "  --help,-h          Print help message"
    echo "  --cluster,-c       Set name of your custer to run the correct Ansible CLUSTER_NAME-site.yml"
    echo "  --playbook,-p      Set name of your playbook to run the correct Ansible playbook"
    echo
}

# Check
if [ ! -f /usr/bin/ansible ]; then
    echo -e "Ansible not found\nPlease install it and run the script again!"
    exit 1
fi

if [ -z $1 ];then
    echo -e "ERROR: Parameters are missing\n"
    Help
    exit 1
fi

while true ; do
    case ${1} in 
        --cluster | -c)
            echo $1
            shift
            CLUSTER_NAME=${1}
            ;;
        --playbook | -p)
            shift
            PLAYBOOK_NAME=${1}
            case ${1} in
                terraform-remove)
                    terraform_remove
                    ;;
                cluster-remove)
                    cluster_remove
                ;;
                cluster-remove-only)
                    cluster_remove_only
                ;;
                database-remove)
                    database_remove
                ;;
                wipe-disks)
                    wipe_disks
                ;;
            esac
            ;;
        --help | -h)
            Help
            ;;
        *)
            echo -e "ERROR: Parameters are missing\n"
            exit 1
            ;;
    esac
shift
done
