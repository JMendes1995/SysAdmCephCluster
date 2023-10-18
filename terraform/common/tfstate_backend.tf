terraform {
  backend "gcs" {
    bucket  = "sysadm_cepth_cluster_tfstate"
    encrypt = true
  }
}