# terraform-aws-static-website-with-cicd

A static s3-backed website with CloudFront, SSL, and automatic deployments on commits to a CodeCommit git repo.
The user can supply a list of IP addresses to whitelist to access the s3-backed website via the whitelisted_ips list.
The whitelist will be implemented via a WAF and WAFRule.
If whitelisted_ips contains an empty list then the WAF and WAFRule will not be allocated.


## Assumptions

This module makes several assumptions:

1. The code for the website is stored in a CodeCommit repository
1. The SSL certificate for the website has been provisioned with the AWS Certificate Manager
1. The build command for the website defaults to a `build` script in the root of the repo
1. The build command places the files to be published into a `public` directory

## Usage

We recommend using aws-vault as a credential store:
https://github.com/99designs/aws-vault

aws-vault comes in very handy during stack deployment (and otherwise):
1. aws-vault exec oe-prod -- terraform init
1. aws-vault exec oe-prod -- terraform apply
1. aws-vault exec oe-prod -- terraform plan

## Example terraform stack needed to deploy the static-website-with-cicd stack

    terraform {
      backend "s3" {
        bucket  = "YOUR_BUCKET_NAME"
        key     = "static-site-example/terraform.tfstate"
        region  = "YOUR_BUCKET_REGION"
      }
    }

    provider "aws" {
      region  = ""
      version = "~> x.x"
    }

    module "static-website-with-cicd" {
      source  = "ordinaryexperts/static-website-with-cicd/aws"
      version = "x.x.x"

      code_build_docker_image_identifier = "aws/codebuild/ruby:2.5.3"
      cert_arn = "YOUR_CERTIFICATE_ARN"
      code_commit_repo_branch = "YOUR_CODE_COMMIT_REPO_BRANCH"
      code_commit_repo_name = "YOUR_CODE_COMMIT_REPO_NAME"
      domain = "static-site-testing.mycompanyname.com"
      env = "test1"
      notification_email = "hello@myemail.com"
      whitelisted_ips = [
        { value = "52.52.11.3/32", type = "IPV4" },
      ]
    }

1. Save the above terraform code into a file called main.tf in a directory of your choice.
1. You will need to choose a unique bucket name for bucket.
1. The bucket region value is "us-west-2" for US-West (Oregon), for example.
1. The region under provider is for the CloudFormation stack.
1. The cert_arn value is the ARN from AWS Certificate Manager.
1. The values for code_commit_repo_branch and code_commit_repo_name are for the code you want to use for your static website.
1. The domain should coincide with the domain of the certificate that cert_arn is refering to.
1. The list of IPs to whitelist are to be specified in whitelisted_ips.

Note: If an empty list is supplied via whitelisted_ips or whitelisted_ips is ommited altogether than a WAF will NOT be created and the static website will be open to the world.
 
## Known Issues / Limitations

None known at this time.

## Variables 

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
      description = "The list of whitelisted IPs to use for the WAF IPSet"
      type = "list"
      default = []
    }

## Outputs

    WebsiteBucket:
      Value: !Ref WebsiteBucket

    WebsiteBucketDns:
      Value: !GetAtt WebsiteBucket.DomainName

    CloudFrontDistributionDomain:
      Value: !GetAtt CloudFrontDistribution.DomainName

    CloudFrontDistributionId:
      Value: !Ref CloudFrontDistribution

## Authors

    Dylan Vaughn -> dylan@ordinaryexperts.com
    Julian Rosenthal -> julian@ordinaryexperts.com

##License

    Apache 2 Licensed. See LICENSE for full details.
