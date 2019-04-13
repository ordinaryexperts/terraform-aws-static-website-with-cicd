# terraform-aws-static-website-with-cicd

A static s3-backed website with CloudFront, SSL, and automatic deployments on commits to a CodeCommit git repo.

## Assumptions

This module makes several assumptions:

1. The code for the website is stored in a CodeCommit repository
1. The SSL certificate for the website has been provisioned with the AWS Certificate Manager
1. The build command for the website defaults to a `build` script in the root of the repo
1. The build command places the files to be published into a `public` directory
