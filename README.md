# eg-terraform

## Steps to provisioning the infra for dev env
```bash
export TF_VAR_aws_region=ap-southeast-1
ENV_PREFIX=dev
terraform init --reconfigure -backend=true -backend-config=env/backend-${ENV_PREFIX}.hcl

terraform plan -var-file=env/dev.tfvars

terraform apply -var-file=env/dev.tfvars
```

## Steps to provisioning the infra for uat env
```bash
export TF_VAR_aws_region=ap-southeast-1
ENV_PREFIX=uat
terraform init --reconfigure -backend=true -backend-config=env/backend-${ENV_PREFIX}.hcl

terraform plan -var-file=env/uat.tfvars

terraform apply -var-file=env/uat.tfvars
```