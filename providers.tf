# # provider
   terraform {
   required_providers {
   aws = {
   source  = "hashicorp/aws"
   version = "~> 5.0"
     }
   }
 }

 # Configure the AWS Provider
   provider "aws" {
   region = "ap-south-1"
   access_key = "AKIAWNAPTNMITMNWPYTO"
   secret_key = "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"
 }
