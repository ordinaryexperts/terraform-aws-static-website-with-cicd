resource "aws_waf_ipset" "whitelisted_ips" {
  count = "${length(var.whitelisted_ips) > 0 ? 1 : 0}"
  name = "WhitelistedIps"

  dynamic "ip_set_descriptors" {
    for_each = var.whitelisted_ips

    content {
      type = ip_set_descriptors.value.type
      value = ip_set_descriptors.value.value
    }
  }

}

resource "aws_waf_rule" "whitelisted_ips_rule" {
  count = "${length(var.whitelisted_ips) > 0 ? 1 : 0}"
  depends_on  = ["aws_waf_ipset.whitelisted_ips"]
  name        = "${var.env}WhitelistedIPsRule"
  metric_name = "${var.env}WhitelistedIPsRule"

  predicates {
    data_id = aws_waf_ipset.whitelisted_ips[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "whitelisted_ips_acl" {
  count = "${length(var.whitelisted_ips) > 0 ? 1 : 0}"
  depends_on  = ["aws_waf_rule.whitelisted_ips_rule"]
  name        = "${var.env}WhitelistedIPsACL"
  metric_name = "${var.env}WhitelistedIPsACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 10
    rule_id  = aws_waf_rule.whitelisted_ips_rule[0].id
    type     = "REGULAR"
  }
}

resource "aws_cloudformation_stack" "website_bucket_and_cf" {
  name = "${var.env}-website-bucket-and-cf-stack"
  capabilities = ["CAPABILITY_IAM"]
  depends_on = ["aws_waf_web_acl.whitelisted_ips_acl"]
  on_failure = "DELETE"
  parameters = {
    CertificateArn = var.cert_arn
    Domain = var.domain
    WebACLId = "${length(var.whitelisted_ips) > 0 ? "${join("", aws_waf_web_acl.whitelisted_ips_acl.*.id)}" : "none"}"
  }
  template_body = "${file("${path.module}/website_bucket_and_cf.yaml")}"
  # CloudFront distributions can take a long time to create...
  timeouts {
    create = "2h"
    delete = "2h"
    update = "4h"
  }

}

resource "aws_cloudformation_stack" "pipeline_bucket" {
  name = "${var.env}-website-pipeline-bucket-stack"
  on_failure = "DELETE"
  template_body = "${file("${path.module}/pipeline_bucket.yaml")}"
}

resource "aws_cloudformation_stack" "website_cicd" {
  capabilities = ["CAPABILITY_IAM"]
  depends_on = ["aws_cloudformation_stack.website_bucket_and_cf"]
  name = "${var.env}-website-cicd-stack"
  on_failure = "DELETE"
  parameters = {
    BuildCommand = var.build_command
    CodeBuildDockerImageIdentifier = var.code_build_docker_image_identifier
    CloudFrontDistributionId = aws_cloudformation_stack.website_bucket_and_cf.outputs["CloudFrontDistributionId"]
    NotificationEmail = var.notification_email
    PipelineBucket = aws_cloudformation_stack.pipeline_bucket.outputs["PipelineBucket"]
    SourceCodeCommitRepoBranch = var.code_commit_repo_branch
    SourceCodeCommitRepoName = var.code_commit_repo_name
    WebsiteBucket = aws_cloudformation_stack.website_bucket_and_cf.outputs["WebsiteBucket"]
  }
  template_body = "${file("${path.module}/website_cicd.yaml")}"
}
