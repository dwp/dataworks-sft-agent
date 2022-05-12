resource "aws_ecr_repository" "dataworks-sft-agent" {
  name = "dataworks-sft-agent"
  tags = merge(
    local.common_tags,
    { DockerHub : "dwpdigital/dataworks-sft-agent" }
  )
}

resource "aws_ecr_repository_policy" "dataworks-sft-agent" {
  repository = aws_ecr_repository.dataworks-sft-agent.name
  policy     = data.terraform_remote_state.management.outputs.ecr_iam_policy_document
}

output "ecr_example_url" {
  value = aws_ecr_repository.dataworks-sft-agent.repository_url
}


resource "aws_ecr_repository" "dataworks-sft-agent-ingress" {
  name = "dataworks-sft-agent-ingress"
  tags = merge(
    local.common_tags,
    { DockerHub : "dwpdigital/dataworks-sft-agent-ingress" }
  )
}

resource "aws_ecr_repository_policy" "dataworks-sft-agent-ingress" {
  repository = aws_ecr_repository.dataworks-sft-agent-ingress.name
  policy     = data.terraform_remote_state.management.outputs.ecr_iam_policy_document
}

output "sft_agent_ingress_url" {
  value = aws_ecr_repository.dataworks-sft-agent-ingress.repository_url
}
