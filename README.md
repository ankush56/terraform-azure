# terraform-azure

create main.tf file
terraform prvovider used to confgure conenction with aws or azure
run -> terraform init--> create .terraform directory--where terraform provider is stored
>- terraform fmt  - format checking
>- terraform plan  - Show what it will do without actually actioning(preview)
>- terraform apply - deploy resources

Use azurerm_resource_name* aliasname* when using/calling output of other resource

Dependency Reference Another resource  - azurerm_resource_group.name*.location
Auto-approve> Terraform apply --auto-approve  (Avoid confirmation input after apply)

terraform state list
terraform state show rgname*  ->  view specific resource
terraform show --> All states
