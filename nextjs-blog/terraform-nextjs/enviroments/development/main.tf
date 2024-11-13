# Declaring Provider connection, to make use of aws services.
provider "aws" {
    region = "eu-north-1"
}


# S3 Bucket Onwership control for ebsite-s3-bucket-tcm.
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id

    # A setup rule for ONLY the bucket owner having full control of the objects within.
    rule {
      object_ownership = "BucketOwnerPrefferred"
    }
}


# Block public Access, block of code for opening access to the S3 bucket to the whole public.
resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id

    # This ensures the S3 Bucket is publically accessable

    # Prevents the Application of public ACL's on the bucket or objects
    block_public_acls = false

    # Prevents the bucket from having a public policy
    block_public_policy = false

    # Ignores any applied acl's to the bucket.
    ignore_public_acls = false
    
    # Prevents the bucket from being a public bucket
    restrict_public_buckets = false
}


# Bucket ACL, opening access as well to the whole public
resource "aws_s3_bucket_acl" "bucket_acl" {

    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id

    # Sets acl to public read perms. Allowing the Objects to be publically read.
    acl = "public-read"

    # Checks on the ownership controls and access public, and ensures they're set first before setting the acl
    depends_on = [
        aws_s3_bucket_ownership_controls.bucket_ownership_controls,
        awaws_s3_bucket_public_access_block.bucket_public_access_block
    ]
}


# Bucket Policy - For defining detailed rules for both bucket and objects
resource "aws_s3_bucket_policy" "bucket_policy" {

    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id
    
    # The policy itself for public access (IAM)
    policy = jsondecode(({
        version = "2012-10-17"
        Statement = [{
            #Policy ID
            Sid = "PublicReadGetObject"
            Effect = "Allow"

            # Applied to all users
            Principal = "*"

            # Allows to get the object from the S3 bucket
            Action = "s3:GetObject"

            # States where the bucket is
            Resource: "${aws_s3_bucket.nextjs_bucket.arn}/*"
        }]
    }))
}