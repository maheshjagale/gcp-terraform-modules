output "project_factory_output" {
  value = var.module_enabled["project-factory"] ? module.project_factory[0] : null
}

output "network_output" {
  value = var.module_enabled["network"] ? module.network[0] : null
}

output "kubernetes_engine_output" {
  value = var.module_enabled["kubernetes-engine"] ? module.kubernetes_engine[0] : null
}

output "vm_output" {
  value = var.module_enabled["vm"] ? module.vm[0] : null
}

output "service_accounts_output" {
  value = var.module_enabled["service-accounts"] ? module.service_accounts[0] : null
}

output "sql_db_output" {
  value = var.module_enabled["sql-db"] ? module.sql_db[0] : null
}

output "bootstrap_output" {
  value = var.module_enabled["bootstrap"] ? module.bootstrap[0] : null
}

output "folders_output" {
  value = var.module_enabled["folders"] ? module.folders[0] : null
}

output "lb_http_output" {
  value = var.module_enabled["lb-http"] ? module.lb_http[0] : null
}

output "iam_output" {
  value = var.module_enabled["iam"] ? module.iam[0] : null
}

output "org_policy_output" {
  value = var.module_enabled["org-policy"] ? module.org_policy[0] : null
}

output "cloud_operations_output" {
  value = var.module_enabled["cloud-operations"] ? module.cloud_operations[0] : null
}

output "cloud_router_output" {
  value = var.module_enabled["cloud-router"] ? module.cloud_router[0] : null
}

output "event_function_output" {
  value = var.module_enabled["event-function"] ? module.event_function[0] : null
}

output "scheduled_function_output" {
  value = var.module_enabled["scheduled-function"] ? module.scheduled_function[0] : null
}

output "container_vm_output" {
  value = var.module_enabled["container-vm"] ? module.container_vm[0] : null
}

output "gke_provision_operator_output" {
  value = var.module_enabled["gke-provision-operator"] ? module.gke_provision_operator[0] : null
}

output "healthcare_output" {
  value = var.module_enabled["healthcare"] ? module.healthcare[0] : null
}

output "artifact_registry_output" {
  value = var.module_enabled["artifact-registry"] ? module.artifact_registry[0] : null
}

output "gcs_output" {
  value = var.module_enabled["gcs"] ? module.gcs[0] : null
}

output "pubsub_output" {
  value = var.module_enabled["pubsub"] ? module.pubsub[0] : null
}

output "bigquery_output" {
  value = var.module_enabled["bigquery"] ? module.bigquery[0] : null
}

output "data_analytics_engine_output" {
  value = var.module_enabled["data-analytics-engine"] ? module.data_analytics_engine[0] : null
}

output "memorystore_redis_output" {
  value = var.module_enabled["memorystore-redis"] ? module.memorystore_redis[0] : null
}

output "cloud_functions_output" {
  value = var.module_enabled["cloud-functions"] ? module.cloud_functions[0] : null
}

output "cloud_run_output" {
  value = var.module_enabled["cloud-run"] ? module.cloud_run[0] : null
}

output "log_export_output" {
  value = var.module_enabled["log-export"] ? module.log_export[0] : null
}

output "kms_output" {
  value = var.module_enabled["kms"] ? module.kms[0] : null
}

output "secrets_manager_output" {
  value = var.module_enabled["secrets-manager"] ? module.secrets_manager[0] : null
}

output "security_center_output" {
  value = var.module_enabled["security-center"] ? module.security_center[0] : null
}

output "monitoring_as_code_output" {
  value = var.module_enabled["monitoring-as-code"] ? module.monitoring_as_code[0] : null
}

output "vpc_sc_output" {
  value = var.module_enabled["vpc-sc"] ? module.vpc_sc[0] : null
}

output "address_output" {
  value = var.module_enabled["address"] ? module.address[0] : null
}

output "bastion_host_output" {
  value = var.module_enabled["bastion-host"] ? module.bastion_host[0] : null
}

output "cloud_nat_output" {
  value = var.module_enabled["cloud-nat"] ? module.cloud_nat[0] : null
}

output "firewall_rules_output" {
  value = var.module_enabled["firewall-rules"] ? module.firewall_rules[0] : null
}

output "google_cloud_armor_output" {
  value = var.module_enabled["google-cloud-armor"] ? module.google_cloud_armor[0] : null
}

output "http_lb_modules_output" {
  value = var.module_enabled["http-lb-modules"] ? module.http_lb_modules[0] : null
}

output "internal_lb_output" {
  value = var.module_enabled["internal-lb"] ? module.internal_lb[0] : null
}

output "load_balancer_output" {
  value = var.module_enabled["load-balancer"] ? module.load_balancer[0] : null
}

output "nat_instance_output" {
  value = var.module_enabled["nat-instance"] ? module.nat_instance[0] : null
}

output "network_peering_output" {
  value = var.module_enabled["network-peering"] ? module.network_peering[0] : null
}

output "subnets_output" {
  value = var.module_enabled["subnets"] ? module.subnets[0] : null
}

output "vpc_flow_logs_output" {
  value = var.module_enabled["vpc-flow-logs"] ? module.vpc_flow_logs[0] : null
}

output "dns_zone_output" {
  value = var.module_enabled["dns-zone"] ? module.dns_zone[0] : null
}

output "cloud_router_bgp_output" {
  value = var.module_enabled["cloud-router-bgp"] ? module.cloud_router_bgp[0] : null
}

output "interconnect_output" {
  value = var.module_enabled["interconnect"] ? module.interconnect[0] : null
}

output "service_networking_output" {
  value = var.module_enabled["service-networking"] ? module.service_networking[0] : null
}

output "shared_vpc_host_output" {
  value = var.module_enabled["shared-vpc-host"] ? module.shared_vpc_host[0] : null
}

output "storage_bucket_output" {
  value = var.module_enabled["storage-bucket"] ? module.storage_bucket[0] : null
}

