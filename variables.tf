variable "build_command" {
  description = "The command that is run via CodeBuild to generate the site"
  default = "if [ -f ./build ]; then chmod 700 ./build && ./build; fi"
}

variable "cert_arn" {
  description = "The ARN of the certification for the site - should include *.example.com and example.com"
}

variable "code_build_docker_image_identifier" {
  description = "Docker Image Identifier: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default = "aws/codebuild/standard:3.0"
}

variable "code_commit_repo_branch" {
  description = "The CodeCommit branch which will trigger deployments"
  default = "master"
}

variable "code_commit_repo_name" {
  description = "The name of the CodeCommit repository hosting the site"
  default = "website"
}

variable "custom_error_response_page_path" {
  description = "The path to an HTML page to use for 403 and 404 errors"
  default = ""
}

variable "debug" {
  description = "Set to 'true' to turn on debugging.  Currently this just sets the TTL for CloudFront to 0"
  default = "false"
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
  description = "The list of whitelisted IPs to use for the WAF IPSet"
  type = "list"
  default = []
}

