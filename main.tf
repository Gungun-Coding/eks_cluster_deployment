resource "aws_eks_cluster" "ankit-cluster" {
  name     = "ankit-cluster"
  role_arn = aws_iam_role.example.arn

vpc_config {
  subnet_ids = [
    "subnet-064060b6947c62a54",  # replace with your actual subnet ID
    "subnet-07f58f491f381fd9a"   # add more if needed
  ]
}

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.ankit-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.ankit-cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.ankit-cluster.name
  node_group_name = "pc-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  
  subnet_ids = [
    "subnet-064060b6947c62a54",
    "subnet-07f58f491f381fd9a"
  ]
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  instance_types  = ["t2.micro"]
  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
    ]  
}
