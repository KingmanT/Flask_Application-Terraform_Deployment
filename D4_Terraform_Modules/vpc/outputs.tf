output "region" {
    value = var.region
}

output "project_name" {
    value = var.project_name
}

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "vpc_cidr" {
    value = var.vpc_cidr
}

output "subnet_id" {
    value = aws_subnet.public_subnet_az1.id
}