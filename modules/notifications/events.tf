# 1. CodePipeline Alerts (Pipeline level)

resource "aws_cloudwatch_event_rule" "pipeline_events" {
  name        = "${var.project_name}-pipeline-rule"
  description = "Capture CodePipeline State Changes"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state = ["FAILED", "SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts.arn
  
  # Optional: Customize the email text (Input Transformer)
  input_transformer {
    input_paths = {
      pipeline = "$.detail.pipeline"
      state    = "$.detail.state"
    }
    input_template = "\"The Pipeline <pipeline> has <state>.\""
  }
}

# 2. CodeBuild Alerts (Build level)

resource "aws_cloudwatch_event_rule" "build_events" {
  name        = "${var.project_name}-build-rule"
  description = "Capture CodeBuild State Changes"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["CodeBuild Build State Change"]
    detail = {
      build-status = ["FAILED", "SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "build_sns" {
  rule      = aws_cloudwatch_event_rule.build_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts.arn
}

# 3. CodeDeploy Alerts (Deployment level)

resource "aws_cloudwatch_event_rule" "deploy_events" {
  name        = "${var.project_name}-deploy-rule"
  description = "Capture CodeDeploy State Changes"

  event_pattern = jsonencode({
    source      = ["aws.codedeploy"]
    detail-type = ["CodeDeploy Deployment State Change"]
    detail = {
      state = ["FAILURE", "SUCCESS"]
    }
  })
}

resource "aws_cloudwatch_event_target" "deploy_sns" {
  rule      = aws_cloudwatch_event_rule.deploy_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts.arn
}
