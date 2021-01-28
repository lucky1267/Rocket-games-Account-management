provider "aws" {
  region  = "eu-central-1"
  version = "2.45.0"
}

terraform {
  required_version = "0.14.5"
}

resource "aws_api_gateway_rest_api" "games-api" {
  name        = "rocket-games-api"
  description = "API for Rocket Games Serverless Application Example "
}


resource "aws_api_gateway_resource" "player" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   parent_id   = aws_api_gateway_rest_api.games-api.root_resource_id
   path_part   = "player"
}
resource "aws_api_gateway_method" "player-method" {
   rest_api_id   = aws_api_gateway_rest_api.games-api.id
   resource_id   = aws_api_gateway_resource.player.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_resource" "studio-ingest" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   parent_id   = aws_api_gateway_rest_api.games-api.root_resource_id
   path_part   = "studio-ingest"
}
resource "aws_api_gateway_method" "studio-ingest-method" {
   rest_api_id   = aws_api_gateway_rest_api.games-api.id
   resource_id   = aws_api_gateway_resource.studio-ingest.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_resource" "rg-owner" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   parent_id   = aws_api_gateway_rest_api.games-api.root_resource_id
   path_part   = "rg-owner"
}
resource "aws_api_gateway_method" "rg-owner-method" {
   rest_api_id   = aws_api_gateway_rest_api.games-api.id
   resource_id   = aws_api_gateway_resource.rg-owner.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_resource" "studio" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   parent_id   = aws_api_gateway_rest_api.games-api.root_resource_id
   path_part   = "studio"
}
resource "aws_api_gateway_method" "studio-method" {
   rest_api_id   = aws_api_gateway_rest_api.games-api.id
   resource_id   = aws_api_gateway_resource.studio.id
   http_method   = "GET"
   authorization = "NONE"
}


resource "aws_api_gateway_integration" "lambda-player" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   resource_id = aws_api_gateway_method.player-method.resource_id
   http_method = aws_api_gateway_method.player-method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda-studio-ingest" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   resource_id = aws_api_gateway_method.studio-ingest-method.resource_id
   http_method = aws_api_gateway_method.studio-ingest-method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda-rg-owner" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   resource_id = aws_api_gateway_method.rg-owner-method.resource_id
   http_method = aws_api_gateway_method.rg-owner-method.http_method

   integration_http_method = "GET"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda-studio" {
   rest_api_id = aws_api_gateway_rest_api.games-api.id
   resource_id = aws_api_gateway_method.studio-method.resource_id
   http_method = aws_api_gateway_method.studio-method.http_method

   integration_http_method = "GET"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "rocket_games_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_iam_role" "rg-api-gatway-lambda" {
  name = "rg_api-gateway-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_lambda_function" "lambda" {
  filename = "lambda.zip"
  function_name = "rocket-games-api-lambda-integration"
  role = aws_iam_role.rg-api-gatway-lambda.arn
  handler = "rocket_games_api_lambda.rg_lambda_handler"
  runtime = "python3.8"

  }

  resource "aws_lambda_permission" "apigw" {
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = "rocket-games-api-lambda-integration"
    principal = "apigateway.amazonaws.com"

    #source_arn = "arn:aws:execute-api:eu-central-1:1234567:aws_api_gateway_rest_api.games-api.id/*/aws_api_gateway_method.player-method.http_method"

  }

  resource "aws_api_gateway_method_response" "player_response_200" {
    rest_api_id = aws_api_gateway_rest_api.games-api.id
    resource_id = aws_api_gateway_resource.player.id
    http_method = aws_api_gateway_method.player-method.http_method
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }

  }
  resource "aws_api_gateway_method_response" "studio_ingest_response_200" {
    rest_api_id = aws_api_gateway_rest_api.games-api.id
    resource_id = aws_api_gateway_resource.studio-ingest.id
    http_method = aws_api_gateway_method.studio-ingest-method.http_method
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }

  }

  resource "aws_api_gateway_method_response" "studio_response_200" {
    rest_api_id = aws_api_gateway_rest_api.games-api.id
    resource_id = aws_api_gateway_resource.studio.id
    http_method = aws_api_gateway_method.studio-method.http_method
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }

  }
  resource "aws_api_gateway_method_response" "rg_owner_response_200" {
    rest_api_id = aws_api_gateway_rest_api.games-api.id
    resource_id = aws_api_gateway_resource.rg-owner.id
    http_method = aws_api_gateway_method.rg-owner-method.http_method
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }

  }

  resource "aws_s3_bucket" "rocket-games-bucket" {
  bucket = "rocket-game-acc-management"
  acl    = "private"

  tags = {
    Name        = "RG-Bucket"
    Environment = "Dev"
  }


}

resource "aws_secretsmanager_secret" "rg-snowflake-secrets" {
  name = "snowflake-secrets"
}






