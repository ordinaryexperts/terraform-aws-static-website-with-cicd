# terraform-aws-static-website-with-cicd

A static s3-backed website with CloudFront, SSL, and automatic deployments on commits to a git repo (CodeCommit natively supported, Bitbucket Cloud, GitHub, GitHub Enterprise Cloud, GitHub Enterprise Server supported via CodeStar connections).
The user can supply a list of IP addresses to whitelist to access the s3-backed website via the whitelisted_ips list.
The whitelist will be implemented via a WAF and WAFRule.
If whitelisted_ips contains an empty list then the WAF and WAFRule will not be allocated.

![AWS Component Diagram](https://github.com/ordinaryexperts/terraform-aws-static-website-with-cicd/raw/master/terraform-aws-static-website-with-cicd.png)

## Assumptions

This module makes several assumptions:

1. US East (N. Virginia) is the AWS region (see Limitations below)
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
      repo_branch = "YOUR_REPO_BRANCH"
      repo_name = "YOUR_REPO_NAME"
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
1. The values for repo_branch and repo_name are for the code you want to use for your static website.
1. The domain should coincide with the domain of the certificate that cert_arn is refering to.
1. The list of IPs to whitelist are to be specified in whitelisted_ips.

Note: If an empty list is supplied via whitelisted_ips or whitelisted_ips is omitted altogether than a WAF will NOT be created and the static website will be open to the world.

### AWS CodeStar for code repositories in Bitbucket and Github

The project default assumes that the website code is hosted in AWS CodeCommit. GitHub and Bitbucket source repositories are supported via integration with AWS CodeStar using an optional parameter to the Terraform module code named `code_star_connection_arn`. The connection ARN should be created in the AWS console as a manual process using one of the following guides from AWS documentation:

* [GitHub connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html)
* [Bitbucket connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-bitbucket.html)

Copy the ARN as specified in the documentation. It should be of the format: `arn:aws:codestar-connections:us-west-2:account_id:connection/aEXAMPLE-8aad-4d5d-8878-dfcab0bc441f`.

Use this value as the input for the `code_star_connection_arn` variable in the Terraform module code.

Also, when using GitHub or Bitbucket, the value for the `repo_name` should be the "full repository id" as specified in the [AWS CodePipeline documentation for CodeStar](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html). This value should take the form `some-user/my-repo`, or `ordinaryexperts/terraform-aws-static-website-with-cicd` for this GitHub project.

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
