# Declaring Provider connection, to make use of aws services.
provider "aws" {
    region = "eu-north-1"
}


# Declares the variable for creating a S3 Bucket
resource "aws_s3_bucket" "nextjs_bucket" {
  # Bucket name, must be globally unique.
  bucket = "website-s3-bucket-tcm"
  
  tags = {
    Name = "Website Bucket"
  }
}

# S3 Bucket Onwership control for ebsite-s3-bucket-tcm.
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id

    # A setup rule for ONLY the bucket owner having full control of the objects within.
    rule {
      object_ownership = "BucketOwnerPreferred"
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
        aws_s3_bucket_public_access_block.bucket_public_access_block
    ]
}


# Bucket Policy - For defining detailed rules for both bucket and objects
resource "aws_s3_bucket_policy" "bucket_policy" {

    # Refering the Bucket ID from Variables
    bucket = aws_s3_bucket.nextjs_bucket.id
    
    # The policy itself for public access (IAM)
    policy = jsonencode({
        Version = "2012-10-17"
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
    })
}

# Origin Access Identity (OAI)
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "OAI for static website portfolio"
}

# Cloudfront distribution
resource "aws_cloudfront_distribution" "website_distribution" {

# Setups up the origin settings for cloudfront
    origin {
      domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
      origin_id = "website-s3-bucket-tcm"

# Settings for S3 origins. In accessing the S3 Bucket. Only Cloudfront can access
      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
      }
    }
  
  # Turns on CloudFront Dist.
  enabled = true

  # Turns on ipv6 support for devices that use ipv6.
  is_ipv6_enabled = true

  # Desc for clear usage of this dist.
  comment = "Website portfolio site"

  # The key root object for this is the website file.
  default_root_object = "index.html"


  default_cache_behavior {
    # Allowing certain Requests from HTTP
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]

    # Common requests are served quickly via caching
    cached_methods = [ "GET", "HEAD" ]

    # Links cache settings to the S3 bucket
    target_origin_id = "website-s3-bucket-tcm"

    # How certain values are forwarded to S3 Bucket
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Ensures user is sent from http to https for secure connection
    viewer_protocol_policy = "redirect-to-https"

    # Cache Object times, for how long an object in cache needs to be refreshed. Making this all quickly accessable
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  # Sets up geo location access, setting to none allows for all geographic locations to access the website
    restrictions {
        geo_restriction {
          restriction_type = "none"
        }
  }

  # Sets up SSL and TSL certs for more security. A Data is then encrypted.
  viewer_certificate {
    cloudfront_default_certificate = true
  }


}