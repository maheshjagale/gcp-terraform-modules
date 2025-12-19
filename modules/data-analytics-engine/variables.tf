
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-central1"
}

variable "dataproc_clusters" {
  type = map(object({
    name           = string
    region         = optional(string)
    staging_bucket = optional(string)
    image_version  = optional(string, "2.1-debian11")
    gce_config = optional(object({
      zone             = optional(string)
      network          = optional(string)
      subnetwork       = optional(string)
      service_account  = optional(string)
      tags             = optional(list(string), [])
      internal_ip_only = optional(bool, true)
    }))
    master_config = object({
      num_instances     = optional(number, 1)
      machine_type      = optional(string, "n1-standard-4")
      boot_disk_type    = optional(string, "pd-standard")
      boot_disk_size_gb = optional(number, 500)
      num_local_ssds    = optional(number, 0)
    })
    worker_config = object({
      num_instances     = optional(number, 2)
      machine_type      = optional(string, "n1-standard-4")
      boot_disk_type    = optional(string, "pd-standard")
      boot_disk_size_gb = optional(number, 500)
      num_local_ssds    = optional(number, 0)
    })
    preemptible_worker_config = optional(object({
      num_instances = number
    }))
    override_properties = optional(map(string), {})
    kms_key_name        = optional(string)
    autoscaling_policy  = optional(string)
    labels              = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Dataproc clusters to create"
}

variable "dataflow_jobs" {
  type = map(object({
    name                    = string
    region                  = optional(string)
    template_gcs_path       = string
    temp_gcs_location       = string
    parameters              = optional(map(string), {})
    machine_type            = optional(string)
    max_workers             = optional(number)
    network                 = optional(string)
    subnetwork              = optional(string)
    service_account_email   = optional(string)
    ip_configuration        = optional(string)
    kms_key_name            = optional(string)
    enable_streaming_engine = optional(bool, false)
    labels                  = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Dataflow jobs to create"
}

variable "composer_environments" {
  type = map(object({
    name       = string
    region     = optional(string)
    node_count = optional(number, 3)
    node_config = optional(object({
      zone            = optional(string)
      machine_type    = optional(string, "n1-standard-1")
      network         = optional(string)
      subnetwork      = optional(string)
      service_account = optional(string)
      tags            = optional(list(string), [])
    }))
    software_config = optional(object({
      image_version            = optional(string)
      python_version           = optional(string, "3")
      airflow_config_overrides = optional(map(string), {})
      pypi_packages            = optional(map(string), {})
      env_variables            = optional(map(string), {})
    }))
    private_environment_config = optional(object({
      enable_private_endpoint    = optional(bool, false)
      master_ipv4_cidr_block     = optional(string)
      cloud_sql_ipv4_cidr_block  = optional(string)
      web_server_ipv4_cidr_block = optional(string)
    }))
    kms_key_name = optional(string)
    labels       = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Composer environments to create"
}
