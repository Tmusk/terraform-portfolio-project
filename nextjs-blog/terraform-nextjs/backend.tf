# Backend File for connecting with AWS' S3 Bucket to store changes and tracked by dynamodb
# Often pre made via AWS Console so the backend is aware where to connect to after int.
terraform{
    backend "s3"{
        # Creates the bucket and gives the name.
        bucket = "my-terraform-state-tcm"

        # Creates the key for the db.
        key = "global/s3/terraform.tfstate"
        region = "eu-north-1"

        # Creates the dynamodb table for tracking changes from other devs.
        dynamodb_table = "s3-backend-table"
    }
}