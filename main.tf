#------------------------------------------------------------
# Local configuration - Default (required). 
#------------------------------------------------------------

locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

resource "azurerm_redis_cache" "main" {
  for_each                      = var.redis_server_settings
  name                          = format("%s", each.key)
  resource_group_name           = local.resource_group_name
  location                      = local.location
  capacity                      = each.value["capacity"]
  family                        = lookup(var.redis_family, each.value.sku_name)
  sku_name                      = each.value["sku_name"]
  enable_non_ssl_port           = each.value["enable_non_ssl_port"]
  minimum_tls_version           = each.value["minimum_tls_version"]
  private_static_ip_address     = each.value["private_static_ip_address"]
  public_network_access_enabled = each.value["public_network_access_enabled"]
  replicas_per_master           = each.value["sku_name"] == "Premium" && { for shard_count, v in var.redis_server_settings : shard_count => v } == null ? each.value["replicas_per_master"] : null
  shard_count                   = { for sku_name, v in var.redis_server_settings : sku_name => v } == "Premium" && { for replicas_per_master, v in var.redis_server_settings : replicas_per_master => v } == null ? each.value["shard_count"] : null
  subnet_id                     = each.value["sku_name"] == "Premium" ? var.subnet_id : null
  zones                         = each.value["zones"]
  tags                          = merge({ "Name" = format("%s", each.key) }, var.tags, )

  redis_configuration {
    enable_authentication           = lookup(var.redis_configuration, "enable_authentication", true)
    maxfragmentationmemory_reserved = lookup(var.redis_configuration, "maxfragmentationmemory_reserved", null)
    maxmemory_delta                 = lookup(var.redis_configuration, "maxmemory_delta")
    maxmemory_policy                = lookup(var.redis_configuration, "maxmemory_policy")
    maxmemory_reserved              = lookup(var.redis_configuration, "maxmemory_reserved")
    notify_keyspace_events          = lookup(var.redis_configuration, "notify_keyspace_events")
    rdb_backup_enabled              = lookup(var.redis_configuration, "rdb_backup_enabled", false)
    rdb_backup_frequency            = { for rdb_backup_enabled, v in var.redis_configuration : rdb_backup_enabled => v } == true ? lookup(var.redis_configuration, "rdb_backup_frequency") : null
    rdb_backup_max_snapshot_count   = { for rdb_backup_enabled, v in var.redis_configuration : rdb_backup_enabled => v } == true ? lookup(var.redis_configuration, "rdb_backup_max_snapshot_count") : null
    rdb_storage_connection_string   = { for rdb_backup_enabled, v in var.redis_configuration : rdb_backup_enabled => v } == true ? lookup(var.redis_configuration, "rdb_storage_connection_string") : null
  }

  lifecycle {
    # A bug in the Redis API where the original storage connection string isn't being returned
    ignore_changes = [redis_configuration.0.rdb_storage_connection_string]
  }

}


