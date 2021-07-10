# Azure Cache for Redis Terraform module

Azure Cache for Redis provides an in-memory data store based on the Redis software. This terraform module helps to quickly create the open-source (OSS Redis) Azure Cache for Redis.

## Resources supported

* [Redis Cache Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
* [Redis Cache Configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache#redis_configuration)
* [Redis Cache Firewall Rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule)
* [Redis Cache Cluser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache#shard_count)
* [Redis Cache Virtual Network Support](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache#subnet_id)
* [Redis Cache Data Persistence](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache#rdb_backup_enabled)
* [Redis Diagnostics](https://docs.microsoft.com/en-us/azure/azure-sql/database/metrics-diagnostic-telemetry-logging-streaming-export-configure?tabs=azure-portal)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)

## Module Usage

```terraform
module "redis" {
  source  = "kumarvna/redis/azurerm"
  version = "1.0.0"

  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  location              = "westeurope"

  # Configuration to provision a Standard Redis Cache
  # Specify `shard_count` to create on the Redis Cluster
  # Add patch_schedle to this object to enable redis patching schedule
  redis_server_settings = {
    demoredischache-shared = {
      sku_name            = "Premium"
      capacity            = 2
      shard_count         = 3
      zones               = ["1", "2", "3"]
      enable_non_ssl_port = true
      patch_schedule = {
        days_of_week   = "Monday"
        start_hour_utc = 21
      }
    }
  }

  # MEMORY MANAGEMENT
  # Azure Cache for Redis instances are configured with the following default Redis configuration values:
  redis_configuration = {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }

  # Nodes are patched one at a time to prevent data loss. Basic caches will have data loss.
  # Clustered caches are patched one shard at a time.
  # The Patch Window lasts for 5 hours from the start_hour_utc
  patch_schedule = {
    days_of_week   = "Monday"
    start_hour_utc = 21
  }

  #Azure Cache for Redis firewall filter rules are used to provide specific source IP access. 
  # Azure Redis Cache access is determined based on start and end IP address range specified. 
  # As a rule, only specific IP addresses should be granted access, and all others denied.
  # "name" (ex. azure_to_azure or desktop_ip) may only contain alphanumeric characters and underscores
  firewall_rules = {
    access_to_azure = {
      start_ip = "1.2.3.4"
      end_ip   = "1.2.3.4"
    },
    desktop_ip = {
      start_ip = "49.204.228.223"
      end_ip   = "49.204.228.223"
    }
  }

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.mysql.database.azure.com` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If using `subnet_id` to create redis cache inside a specified virtual network
  enable_private_endpoint       = true
  virtual_network_name          = "vnet-shared-hub-westeurope-001"
  private_subnet_address_prefix = ["10.1.5.0/29"]
  #  existing_private_dns_zone     = "demo.example.com"

  # (Optional) To enable Azure Monitoring for Azure Cache for Redis
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

Schedule maintenance for Redis. The default maintenance window is 5 hours
This does not cover any maintenance done by Azure for updating the underlying platform.
