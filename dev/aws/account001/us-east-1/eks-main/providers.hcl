
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "helm" {
  kubernetes {
    host                   = "${dependency.eks.outputs.eks_endpoint}"
    cluster_ca_certificate = "${replace(base64decode(dependency.eks.outputs.eks_certificate), "\n", "\\n")}"
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.eks_cluster_name}"]
    }
  }
}

provider "kubectl" {
  host                   = "${dependency.eks.outputs.eks_endpoint}"
  cluster_ca_certificate = "${replace(base64decode(dependency.eks.outputs.eks_certificate), "\n", "\\n")}"
  load_config_file       = false
  apply_retry_count      = 5
    
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.eks_cluster_name}"]
  }
}

provider "kubernetes" {
  host                   = "${dependency.eks.outputs.eks_endpoint}"
  cluster_ca_certificate = "${replace(base64decode(dependency.eks.outputs.eks_certificate), "\n", "\\n")}"
  experiments {
    manifest_resource = true
  }
    
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.eks_cluster_name}"]
  }
}
  EOF
}