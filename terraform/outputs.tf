output "vpc_id" {
  value = aws_vpc.drupal_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "availability_zones" {
  value = [
    aws_subnet.public_a.availability_zone,
    aws_subnet.public_b.availability_zone
  ]
}
