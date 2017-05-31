# Hubot CI

### Uses CircleCI, AWS Elastic Container Registry and Container Service

## Required ENV for CircleCI

- `SLACK_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Required AWS Policy for CircleCI's IAM User

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1496174617000",
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1496169802000",
            "Effect": "Allow",
            "Action": [
                "ecs:RegisterTaskDefinition"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1496172014000",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

TODO: ECR Policies

## Deployment

Pushes to master will automatically deploy on AWS ECR/ECS

## Local development

`docker build -t hubot .`

`docker run -e HUBOT_SLACK_TOKEN=$SLACK_TOKEN --label name=hubot hubot`
