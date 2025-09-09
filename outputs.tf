# -------------------------
# EC2 Outputs
# -------------------------
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app.public_dns
}

# -------------------------
# EKS Outputs
# -------------------------
output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.trend.name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Server Endpoint"
  value       = aws_eks_cluster.trend.endpoint
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.trend.arn
}

output "eks_nodegroup_name" {
  description = "EKS Node Group Name"
  value       = aws_eks_node_group.trend_nodes.node_group_name
}

