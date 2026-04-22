module "vpc" {
    source = "git::https://github.com/e-shekharreddy/terraform-aws-vpc.git?ref=main"
    project = var.project
    environment = var.environment
    is_peering_required = true 
}

# for i in 00-vpc/ 05-sg/ 10-sg-rules/ 15-bastion/ 25-backend-alb/ 35-acm/ 40-frontend-alb/ 50-cdn/ do cd $i; terraform apply -auto-approve; cd ..;done

# for i in $(ls -dr *); do cd $i; terraform init; terraform destroy -auto-approve; cd ..;done