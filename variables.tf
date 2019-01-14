variable "build_command" {
  description = ""
  default = "bash ./build.sh"
}

variable "cert_arn" {
  description = ""
}

variable "code_build_docker_image_identifier" {
  description = "Docker Image Identifier: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default = "aws/codebuild/ubuntu-base:14.04"
}

variable "code_commit_repo_branch" {
  description = ""
}

variable "code_commit_repo_name" {
  description = ""
}

variable "env" {
  description = ""
}

variable "url" {
  description = ""
}
