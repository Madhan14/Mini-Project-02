# EC2 Outputs
output "ec2_public_ip" {
  value       = aws_instance.trend_app.public_ip
  description = "Public IP of EC2 instance"
}

output "ec2_public_dns" {
  value       = aws_instance.trend_app.public_dns
  description = "Public DNS of EC2 instance"
}

# EKS Outputs
output "eks_cluster_name" {
  value       = aws_eks_cluster.trend_cluster.name
  description = "EKS Cluster Name"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.trend_cluster.endpoint
  description = "EKS Cluster API Server Endpoint"
}

output "eks_cluster_arn" {
  value       = aws_eks_cluster.trend_cluster.arn
  description = "EKS Cluster ARN"
}

output "eks_nodegroup_name" {
  value       = aws_eks_node_group.trend_node_group.node_group_name
  description = "EKS Node Group Name"
}
