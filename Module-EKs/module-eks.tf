module "EKS" {
    source = "../Main-eks"

    region_eks = var.region
    auth_mode_eks = var.auth_mode
    version_cluster_eks = var.version_cluster
  
}