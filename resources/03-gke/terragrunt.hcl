# Include all settings from the parent terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "common" {
  config_path = "../01-common"
  mock_outputs = {
    project_number = 12345
    remote_ip      = "192.168.168.192/32"
    unique_id      = "abcde",
    zone           = "europe-west1-b",
    zones          = ["europe-west1-b"],
  }
}

dependency "network" {
  config_path = "../02-network"
  mock_outputs = {
    network_name           = "network_name",
    subnets_ip_cidr_ranges = ["10.0.0.0/16"],
    subnets_names          = ["subnets_names"],
  }
}

locals {
  cluster_name_prefix    = "public"
  common_vars            = jsondecode(file("${get_parent_terragrunt_dir()}/common_vars.json"))
  machine_type           = lookup(local.common_vars, "gke_machine_type", "e2-standard-2")
  master_ipv4_cidr_block = lookup(local.common_vars, "master_ipv4_cidr_block", "172.16.0.0/28")
  min_count              = lookup(local.common_vars, "gke_nodes_min", 1)
  max_count              = lookup(local.common_vars, "gke_nodes_max", 3)
  node_pool_name         = "private-node-pool"
  preemptible            = lookup(local.common_vars, "preemptible", true)
  regional               = lookup(local.common_vars, "gke_regional", true)
  skip                   = lookup(local.common_vars, "skip_gke", false)
}

terraform {
  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-private-cluster?ref=v18.0.0"
}

inputs = {
  create_service_account     = true
  enable_private_endpoint    = false
  enable_private_nodes       = true
  horizontal_pod_autoscaling = true
  initial_node_count         = 0
  ip_range_pods              = "gke-pods"
  ip_range_services          = "gke-services"
  master_ipv4_cidr_block     = local.master_ipv4_cidr_block
  name                       = format("%s-%s", local.cluster_name_prefix, dependency.common.outputs.unique_id)
  network                    = dependency.network.outputs.network_name
  region                     = local.regional == true ? local.common_vars.region : null
  regional                   = local.regional
  remove_default_node_pool   = true
  subnetwork                 = dependency.network.outputs.subnets_names[0]
  project_id                 = local.common_vars.project_id
  cluster_resource_labels = {
    "mesh_id" : format("proj-%s", dependency.common.outputs.project_number)
  }

  master_authorized_networks = [
    {
      cidr_block   = dependency.common.outputs.remote_ip,
      display_name = "remote-ip"
    }
  ]

  node_pools = [
    {
      disk_size_gb       = "50"
      disk_type          = "pd-ssd"
      initial_node_count = local.min_count
      min_count          = local.min_count
      max_count          = local.max_count
      machine_type       = local.machine_type
      name               = local.node_pool_name
      preemptible        = local.preemptible
    }
  ]

  node_pools_oauth_scopes = {
    private-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_tags = {
    private-node-pool = [
      format("%s-%s", local.cluster_name_prefix, dependency.common.outputs.unique_id)
    ]
  }

  # Single zone or all zones dependant on zonal or regional cluster
  zones = local.regional == true ? dependency.common.outputs.zones : [dependency.common.outputs.zone]
}

skip = local.skip