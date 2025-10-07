resource "aws_s3_bucket" "source" {
  provider = aws.south
  bucket   = "chinmaya-terraform-state-source"
}

resource "aws_s3_bucket_versioning" "source-versioning" {
  provider = aws.south
  bucket = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  provider = aws.east
  bucket   = "chinmaya-terraform-state-destination"
}

resource "aws_s3_bucket_versioning" "destination-versioning" {
  provider = aws.east
  bucket = aws_s3_bucket.destination.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ----------------------------
# IAM Role for S3 Replication
# ----------------------------
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "replication-role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Principal = {
              Service = "s3.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy" "replication-policy" {
  name = "s3-replication-policy"
  description = "Policy for S3 bucket replication"


  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
              "s3:GetReplicationConfiguration",
              "s3:ListBucket"
            ],
            Resource = aws_s3_bucket.source.arn
        },
        {
            Effect = "Allow",
            Action = [
              "s3:GetObjectVersion",
              "s3:GetObjectVersionForReplication",
              "s3:GetObjectVersionTagging",
              "s3:GetObjectVersionAcl"
            ],
            Resource = "${aws_s3_bucket.source.arn}/*"
        },
        {
            Effect = "Allow",
            Action = [
              "s3:ReplicateObject",
              "s3:ReplicateDelete",
              "s3:ReplicateTags"
            ],
            Resource = "${aws_s3_bucket.destination.arn}/*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication-attach" {
  role = aws_iam_role.replication-role.name
  policy_arn = aws_iam_policy.replication-policy.arn
}

# -----------------------------
# S3 Replication Configuration
# -----------------------------
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.south
  # Must have bucket versioning enabled first
  depends_on = [ aws_s3_bucket_versioning.source-versioning, aws_s3_bucket_versioning.destination-versioning ]

  bucket = aws_s3_bucket.source.id

  role = aws_iam_role.replication-role.arn

  rule {
    id = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }

    filter {
      prefix = ""
    }
  }
}

# ---------------------------
# DynamoDB for state locking
# ---------------------------
resource "aws_dynamodb_table" "terraform-locks" {
  provider = aws.south
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}