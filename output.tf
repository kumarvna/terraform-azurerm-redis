output "redis_cache_instance_id" {
  description = "The Route ID of Redis Cache Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.id }
}

output "redis_cache_hostname" {
  description = "The Hostname of the Redis Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.hostname }
}

output "redis_cache_ssl_port" {
  description = "The SSL Port of the Redis Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.ssl_port }
}

output "redis_cache_port" {
  description = "The non-SSL Port of the Redis Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.port }
}

output "redis_cache_primary_access_key" {
  description = "The Primary Access Key for the Redis Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.primary_access_key }
  sensitive   = true
}

output "redis_cache_secondary_access_key" {
  description = "The Secondary Access Key for the Redis Instance"
  value       = { for k, v in azurerm_redis_cache.main : k => v.secondary_access_key }
  sensitive   = true
}

output "redis_cache_primary_connection_string" {
  description = "The primary connection string of the Redis Instance."
  value       = { for k, v in azurerm_redis_cache.main : k => v.primary_connection_string }
  sensitive   = true
}

output "redis_cache_secondary_connection_string" {
  description = "The secondary connection string of the Redis Instance."
  value       = { for k, v in azurerm_redis_cache.main : k => v.secondary_connection_string }
  sensitive   = true
}

output "redis_configuration_maxclients" {
  description = "Returns the max number of connected clients at the same time."
  value       = { for k, v in azurerm_redis_cache.main : k => v.redis_configuration.0.maxclients }
}
