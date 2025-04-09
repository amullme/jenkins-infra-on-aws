terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.16"
    }
  }

  backend "s3" {
    bucket = "a-fake-bucket" # replace with your own bucket
    key    = "a-fake-key"    # replace with your own key
    region = "us-east-1"     # replace with the region in which your bucket resides
  }
  
  required_version = ">= 1.2.0"

}