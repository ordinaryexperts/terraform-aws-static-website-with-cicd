resource "aws_cloudformation_stack" "website_bucket_and_cf" {
  name = "${var.env}-website-bucket-and-cf-stack"
  on_failure = "DELETE"
  parameters {
    CertificateArn = "${var.cert_arn}"
    Url = "${var.url}"
  }
  template_body = "${file("${path.module}/website_bucket_and_cf.yaml")}"
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
  parameters {
    CloudFrontDistributionId = "${aws_cloudformation_stack.website_bucket_and_cf.outputs["CloudFrontDistributionId"]}"
    PipelineBucket = "${aws_cloudformation_stack.pipeline_bucket.outputs["PipelineBucket"]}"
    SourceCodeCommitRepoBranch = "${var.code_commit_repo_branch}"
    SourceCodeCommitRepoName = "${var.code_commit_repo_name}"
    WebsiteBucket = "${aws_cloudformation_stack.website_bucket_and_cf.outputs["WebsiteBucket"]}"
  }
  template_body = "${file("${path.module}/website_cicd.yaml")}"
}