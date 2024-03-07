resource "mongodbatlas_advanced_cluster" "east" {
  project_id   = var.project_id
  name         = "TF-east-region"
  cluster_type = "REPLICASET"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.instance_size
        node_count    = 3
      }
      analytics_specs {
        instance_size = var.instance_size
        node_count    = 0
      }
      provider_name = "AWS"
      priority      = 7
      region_name   = "US_EAST_2"
    }
  }
}

resource "mongodbatlas_advanced_cluster" "west" {
  project_id   = var.project_id
  name         = "TF-west-region"
  cluster_type = "REPLICASET"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.instance_size
        node_count    = 3
      }
      analytics_specs {
        instance_size = var.instance_size
        node_count    = 0
      }
      provider_name = "AWS"
      priority      = 7
      region_name   = "US_WEST_1"
    }
  }
}