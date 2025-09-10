# -------------------------
# IAM Role for EKS Cluster
# -------------------------
resource "aws_iam_role" "trend_eks_cluster_role" {
  name = "trend-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "trend_eks_cluster_policy" {
  role       = aws_iam_role.trend_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# -------------------------
# IAM Role for Worker Nodes
# -------------------------
resource "aws_iam_role" "trend_eks_node_role" {
  name = "trend-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "trend_node_worker_policy" {
  role       = aws_iam_role.trend_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "trend_node_ecr_policy" {
  role       = aws_iam_role.trend_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "trend_node_cni_policy" {
  role       = aws_iam_role.trend_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# -------------------------
# EKS Cluster
# -------------------------
resource "aws_eks_cluster" "trend_cluster" {
  name     = "trend-eks-cluster"
  role_arn = aws_iam_role.trend_eks_cluster_role.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.trend_eks_cluster_policy]
}

# -------------------------
# Node Group
# -------------------------
resource "aws_eks_node_group" "trend_node_group" {
  cluster_name    = aws_eks_cluster.trend_cluster.name
  node_group_name = "trend-eks-nodes"
  node_role_arn   = aws_iam_role.trend_eks_node_role.arn

  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.medium"]
  ami_type       = "AL2_x86_64"

  depends_on = [
    aws_iam_role_policy_attachment.trend_node_worker_policy,
    aws_iam_role_policy_attachment.trend_node_ecr_policy,
    aws_iam_role_policy_attachment.trend_node_cni_policy
  ]
}
