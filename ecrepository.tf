#ECR
resource "aws_ecr_repository" "exam_repository" {
  name = "exam-project"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "My exam project"
  }
}