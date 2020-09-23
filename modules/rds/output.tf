output "db_sg_id" {
  value = aws_db_subnet_group.default.id
}

output "db_connection" {
  value = aws_db_instance.db.endpoint
}
