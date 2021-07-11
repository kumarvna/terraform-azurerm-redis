output "redis_cache_instance_id" {
  description = "The Route ID of Redis Cache Instance"
  value       = element(concat([for n in azurerm_redis_cache.main : n.id], [""]), 0)
}

output "redis_cache_hostname" {
  description = "The Hostname of the Redis Instance"
  value       = element(concat([for h in azurerm_redis_cache.main : h.hostname], [""]), 0)
}

output "redis_cache_ssl_port" {
  description = "The SSL Port of the Redis Instance"
  value       = element(concat([for p in azurerm_redis_cache.main : p.ssl_port], [""]), 0)
}

output "redis_cache_port" {
  description = "The non-SSL Port of the Redis Instance"
  value       = element(concat([for p in azurerm_redis_cache.main : p.port if p == true], [""]), 0)
  sensitive   = true
}

output "redis_cache_primary_access_key" {
  description = "The Primary Access Key for the Redis Instance"
  value       = element(concat([for a in azurerm_redis_cache.main : a.primary_access_key], [""]), 0)
  sensitive   = true
}

output "redis_cache_secondary_access_key" {
  description = "The Secondary Access Key for the Redis Instance"
  value       = element(concat([for a in azurerm_redis_cache.main : a.secondary_access_key], [""]), 0)
  sensitive   = true
}

output "redis_cache_primary_connection_string" {
  description = "The primary connection string of the Redis Instance."
  value       = element(concat([for c in azurerm_redis_cache.main : c.primary_connection_string], [""]), 0)
  sensitive   = true
}

output "redis_cache_secondary_connection_string" {
  description = "The secondary connection string of the Redis Instance."
  value       = element(concat([for a in azurerm_redis_cache.main : a.secondary_connection_string], [""]), 0)
  sensitive   = true
}

output "redis_configuration_maxclients" {
  description = "Returns the max number of connected clients at the same time."
  value       = element(concat([for m in azurerm_redis_cache.main : m.redis_configuration.0.maxclients], [""]), 0)
}

output "redis_cache_private_endpoint" {
  description = "id of the Redis Cache server Private Endpoint"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_endpoint.pep1.*.id, [""]), 0) : null
}

output "redis_cache_private_dns_zone_domain" {
  description = "DNS zone name of Redis Cache server Private endpoints dns name records"
  value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? element(concat(azurerm_private_dns_zone.dnszone1.*.name, [""]), 0) : var.existing_private_dns_zone
}

output "redis_cache_private_endpoint_ip" {
  description = "Redis Cache server private endpoint IPv4 Addresses"
  value       = var.enable_private_endpoint ? element(concat(data.azurerm_private_endpoint_connection.private-ip1.*.private_service_connection.0.private_ip_address, [""]), 0) : null
}

output "redis_cache_private_endpoint_fqdn" {
  description = "Redis Cache server private endpoint FQDN Addresses"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_dns_a_record.arecord1.*.fqdn, [""]), 0) : null
}

