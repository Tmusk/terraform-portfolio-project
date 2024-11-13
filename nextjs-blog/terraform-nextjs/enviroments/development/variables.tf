
# Declares the variable for creating a S3 Bucket
resource "aws_s3_bucket" "nextjs_bucket" {
  # Bucket name, must be globally unique.
  bucket = "website-s3-bucket-tcm"
  
  tags = {
    Name = "Website Bucket"
  }
}