#!/bin/sh -e

MISSING_VARS=""
[[ ! -z "${AWS_REGION}" ]] || MISSING_VARS="${MISSING_VARS},AWS_REGION"
[[ ! -z "${AWS_ACCESS_KEY_ID}" ]] || MISSING_VARS="${MISSING_VARS},AWS_ACCESS_KEY_ID"
[[ ! -z "${AWS_SECRET_ACCESS_KEY}" ]] || MISSING_VARS="${MISSING_VARS},AWS_SECRET_ACCESS_KEY"
[[ -z "${MISSING_VARS}" ]] || (echo "Please specify required variables: ${MISSING_VARS#,}" && exit 1)


export TF_VAR_aws_region="${AWS_REGION}"
terraform init /plan

if [[ "$1" == "create" ]]; then
    terraform apply -state="/output/rodemo.tfstate" /plan
    echo "Your IP: $(cat /output/public_ip.txt)"
elif [[ "$1" == "plan" ]]; then
    terraform plan -state="/output/rodemo.tfstate" /plan
elif [[ "$1" == "destroy" ]]; then
    terraform destroy -state="/output/rodemo.tfstate" /plan
fi
