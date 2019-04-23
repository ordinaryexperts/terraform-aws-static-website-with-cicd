variable "build_command" {
  description = "The command that is run via CodeBuild to generate the site"
  default = "if [ -f ./build ]; then chmod 700 ./build && ./build; fi"
}

variable "cert_arn" {
  description = "The ARN of the certification for the site - should include *.example.com and example.com"
}

variable "code_build_docker_image_identifier" {
  description = "Docker Image Identifier: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default = "aws/codebuild/ubuntu-base:14.04"
}

variable "code_commit_repo_branch" {
  description = "The CodeCommit branch which will trigger deployments"
  default = "master"
}

variable "code_commit_repo_name" {
  description = "The name of the CodeCommit repository hosting the site"
  default = "website"
}

variable "domain" {
  description = "The URL or domain for the site, without the 'www', i.e. example.com"
}

variable "env" {
  description = "The name of the environment, i.e. dev, test, prod; will be used to prefix CloudFormation stack names"
}

variable "notification_email" {
  description = "Email address which should receive deploy notifications"
  default = ""
}

variable "whitelisted_ips" {
  type = "list"
  description = "The list of whitelisted IPs to use for the WAF IPSet"
}

