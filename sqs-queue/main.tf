provider "aws" {
  region = var.aws_region
}

resource "aws_sqs_queue" "test_queue" {
  name                      = "${var.sqs_prefix}-${var.env_name}"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  # sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.test_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Env = var.env_name
  }

  depends_on = [
    aws_sqs_queue.test_queue_deadletter
  ]
}

resource "aws_sqs_queue" "test_queue_deadletter" {
  name = "deadletter-${var.sqs_prefix}-${var.env_name}"

  # redrive_allow_policy = jsonencode({
  #   redrivePermission = "byQueue",
  #   sourceQueueArns   = [aws_sqs_queue.test_queue.arn]
  # })
}
