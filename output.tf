output "VPC_ID" {
    value = aws_vpc.TTA-VPC.id
}

output "Public_subnet_1" {
    value = aws_subnet.Public-subnet-1.id
}

output "Public_subnet_1_cidr_block" {
    value = aws_subnet.Public-subnet-1.cidr_block
}

output "Public_subnet_2" {
    value = aws_subnet.Public-subnet-2.id
}

output "Public_subnet_2_cidr_block" {
    value = aws_subnet.Public-subnet-2.cidr_block
}
output "Private_subnet_1" {
    value = aws_subnet.Private-subnet-1.id
}

output "Private_subnet_1_cidr_block" {
    value = aws_subnet.Private-subnet-1.cidr_block
}
output "Private_subnet_2" {
    value = aws_subnet.Private-subnet-2.id
}

output "Private_subnet_2_cidr_block" {
    value = aws_subnet.Private-subnet-2.cidr_block
}
output "NAT_Gateway" {
    value = aws_eip.nat_gateway.id
}

output "RDS_Instance_endpoint" {
    value = aws_db_instance.TTA_RDS.endpoint
}

output "RDS_Instance_Replica_endpoint" {
    value = aws_db_instance.TTA__Replica_RDS.endpoint
}

output "ALB_DNS" {
    value = aws_lb.TTA-ALB.dns_name
}