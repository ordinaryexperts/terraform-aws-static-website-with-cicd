# terraform-aws-static-website-with-cicd

A static s3-backed website with CloudFront, SSL, and automatic deployments on commits to a CodeCommit git repo.
The user can supply a list of IP addresses to whitelist to access the s3-backed website via the whitelisted_ips list.
The whitelist will be implemented via a WAF and WAFRule.
If whitelisted_ips contains an empty list then the WAF and WAFRule will not be allocated.

![AWS Component Diagram](https://github.com/ordinaryexperts/terraform-aws-static-website-with-cicd/raw/master/terraform-aws-static-website-with-cicd.png)

## Assumptions

This module makes several assumptions:

1. US East (N. Virginia) is the AWS region (see Limitations below)
1. The code for the website is stored in a CodeCommit repository
1. The SSL certificate for the website has been provisioned with the AWS Certificate Manager
1. The build command for the website defaults to a `build` script in the root of the repo
1. The build command places the files to be published into a `public` directory

## Usage

We recommend using aws-vault as a credential store:

https://github.com/99designs/aws-vault

aws-vault comes in very handy during stack deployment (and otherwise):

    $ aws-vault exec oe-prod -- terraform init
    $ aws-vault exec oe-prod -- terraform apply
    $ aws-vault exec oe-prod -- terraform plan

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
1. The bucket region value is "us-east-1" for US East (N. Virginia), for example.
1. The region under provider is for the CloudFormation stack.
1. The cert_arn value is the ARN from AWS Certificate Manager.
1. The values for code_commit_repo_branch and code_commit_repo_name are for the code you want to use for your static website.
1. The domain should coincide with the domain of the certificate that cert_arn is refering to.
1. The list of IPs to whitelist are to be specified in whitelisted_ips.

Note: If an empty list is supplied via whitelisted_ips or whitelisted_ips is ommited altogether than a WAF will NOT be created and the static website will be open to the world.
 
## Known Issues / Limitations

*Must be launched in US East (N. Virginia)*

Why? Lambda@Edge functions can only be deployed into us-east-1 at this time.

*Lambda@Edge function is not deleted when stack is deleted*

Why? Lambda@Edge functions can only be deleted hours after their CloudFront distribution is deleted:

https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html

## Variables 

https://github.com/ordinaryexperts/terraform-aws-static-website-with-cicd/blob/master/variables.tf

## Outputs

https://github.com/ordinaryexperts/terraform-aws-static-website-with-cicd/blob/master/outputs.tf

## Authors

    Dylan Vaughn -> dylan@ordinaryexperts.com
    Julian Rosenthal -> julian@ordinaryexperts.com

## License

    MIT License. See LICENSE for full details.
