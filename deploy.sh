#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

deploy_image() {
  docker info
  docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest
  docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG
  docker tag -f $DOCKER_IMAGE:latest $DOCKER_REGISTRY/$DOCKER_IMAGE:latest
  docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG | cat # cat circle workaround
  docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:latest | cat # cat circle workaround
}

make_task_def() {

  task_template='[
    {
      "name": "hubot",
      "image": "%s/%s:%s",
      "memory": 3767,
      "cpu": 2048,
      "essential": true,
      "environment": [
        { "name": "HUBOT_SLACK_TOKEN", "value": "%s" }
      ]
    }
  ]'

  task_def=$(printf "$task_template" $DOCKER_REGISTRY $DOCKER_IMAGE $DOCKER_TAG $SLACK_TOKEN)
}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi

}

deploy_cluster() {

    family="hubot-ecs-cluster"
    cluster="hubot-ecs-cluster"
    service="hubot-ecs-service"

    make_task_def
    register_definition

    if [[ $(aws ecs update-service --cluster $cluster --service $service --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    for attempt in {1..30}; do
        if stale=$(aws ecs describe-services --cluster $cluster --services $service | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 5
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1
}

echo -e "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\nus-east-1\njson" | aws configure
DOCKER_LOGIN=`aws ecr get-login`
DOCKER_REGISTRY=`echo $DOCKER_LOGIN | sed 's|.*https://||'`
eval "$DOCKER_LOGIN"

deploy_image
deploy_cluster
