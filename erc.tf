
# 1- Us_west-1
resource "aws_ecr_repository" "ecr_repo" {
  provider = aws.west
  name                 = "docker_ecr_repo"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }

  provisioner "local-exec" {
    working_dir = "nginx"
    command     = "chmod +x update-ecr.sh && sh -x update-ecr.sh"
  }

#   depends_on = [aws_ecr_repository.ecr_repo, aws_ecr_lifecycle_policy.ecr_policy, aws_ecr_repository_policy.demo-repo-policy]
  tags = {
    Name  = "worker-repository"
    Group = "test"
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  provider = aws.west
  repository = aws_ecr_repository.ecr_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "demo-repo-policy" {
  provider = aws.west
  repository = aws_ecr_repository.ecr_repo.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "Set the permission for ECR",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

# resource "null_resource" "update_docker_fund" {
#   provider = aws.west
#   provisioner "local-exec" {
#     working_dir = "nginx"
#     command     = "chmod +x update-ecr.sh && sh -x update-ecr.sh"
#   }

#   depends_on = [aws_ecr_repository.ecr_repo, aws_ecr_lifecycle_policy.ecr_policy, aws_ecr_repository_policy.demo-repo-policy]
# }

#-------------------------------------------------------

#2- Us-east-1

resource "aws_ecr_repository" "ecr_repo_2" {
  name                 = "docker_ecr_repo"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  provisioner "local-exec" {
  working_dir = "nginx"
  command     = "chmod +x update-ecr.sh && sh -x update-ecr.sh"
  }

#   depends_on = [aws_ecr_repository.ecr_repo_2, aws_ecr_lifecycle_policy.ecr_policy_2, aws_ecr_repository_policy.demo-repo-policy_2]

  tags = {
    Name  = "worker-repository"
    Group = "test"
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy_2" {
  repository = aws_ecr_repository.ecr_repo_2.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "demo-repo-policy_2" {
  repository = aws_ecr_repository.ecr_repo_2.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "Set the permission for ECR",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

# resource "null_resource" "update_docker_fund_2" {
#   provisioner "local-exec" {
#     working_dir = "nginx"
#     command     = "chmod +x update-ecr.sh && sh -x update-ecr.sh"
#   }

#   depends_on = [aws_ecr_repository.ecr_repo_2, aws_ecr_lifecycle_policy.ecr_policy_2, aws_ecr_repository_policy.demo-repo-policy_2]
# }
