export TF_VAR_aws_region=ap-southeast-1
ENV_PREFIX=dev
terraform init --reconfigure -backend=true -backend-config=env/backend-${ENV_PREFIX}.hcl