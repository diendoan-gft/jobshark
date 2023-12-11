output "db" {
  value = {
    user = module.db.db_instance_username
  }
  sensitive = true
}
