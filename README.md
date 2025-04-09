# Setup a Jenkins controller on EC2

## Pre-reqs

- Install Terraform and AWS cli
- Set up IAM identity center for use with AWS cli and store your info: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html
- Create a private S3 bucket to store your Terraform state file
- Create a key pair within AWS EC2, ideally named `jenkins_kp` and download the PEM

## Build the infra
- Clone this repo locally
- Run the following commands from the root of the repo
```
cp ./templates/template.tfvars custom.tfvars
cp ./templates/template.tf custom.tf
```
- Using the comments within each file, customize the information in the newly created files `custom.tvars` and `custom.tf`. FYI, Github will ignore these files.
- Log in to AWS cli
- Build the infra with the commands below
```
terraform init
terraform apply -auto-approve
```
- Connect via ssh by getting the command from the AWS console: EC2 > Instances > Connect > SSH Client tab. The command should look like this
```
ssh -i "jenkins_kp.pem" ec2-user@hostname.compute-1.amazonaws.com
```
- Get the Jenkins init password
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
- In a browser, open Jenkins on port 8080. The URL should look like this
```
http://hostname.amazonaws.com:8080
```
- Login with the init password.
- Install suggested plugins.
- Choose a password and other login info.

## Destroy the infra

```
terraform destroy -auto-approve
```
