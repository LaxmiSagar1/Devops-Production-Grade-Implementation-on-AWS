# Datasource: Get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "metrics_server_default" {
  addon_name         = "metrics-server"
  kubernetes_version = aws_eks_cluster.main.version
}

# Datasource: Get the latest available Metrics Server addon version

data "aws_eks_addon_version" "metrics_server_latest" {
  addon_name         = "metrics-server"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

# Resource: Install Metrics Server addon

resource "aws_eks_addon" "metrics_server" {
  depends_on = [
    aws_eks_node_group.private_nodes
  ]

  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "metrics-server"
  addon_version = data.aws_eks_addon_version.metrics_server_latest.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${local.name}-metrics-server-addon"
    Environment = var.environment_name
    Component   = "Metrics Server"
  }
}

# Outputs

output "metrics_server_eksaddon_default_version" {
  value = data.aws_eks_addon_version.metrics_server_default.version
}

output "metrics_server_eksaddon_latest_version" {
  value = data.aws_eks_addon_version.metrics_server_latest.version
}

output "metrics_server_eksaddon_arn" {
  value = aws_eks_addon.metrics_server.arn
}

output "metrics_server_eksaddon_id" {
  value = aws_eks_addon.metrics_server.id
}