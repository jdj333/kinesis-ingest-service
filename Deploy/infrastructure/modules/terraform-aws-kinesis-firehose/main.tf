resource "aws_kinesis_stream" "delivery_stream" {
  name             = "kinesis-firehose-twitter-delivery-stream"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = var.environment,
    Application = var.application
  }
}

