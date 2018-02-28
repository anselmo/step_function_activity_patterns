#!/bin/bash

#/home/hadoop/stepfunctions-scripts/get_activity_task.sh --activity-arn "$ACTIVITY_ARN"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -a|--activity-arn)
      ACTIVITY_ARN="$2"
      shift
      shift
      ;;
      *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

echo ACTIVITY_ARN = "${ACTIVITY_ARN}"
jobflowid=$(cat /mnt/var/lib/info/job-flow.json | jq -r ".jobFlowId")

activity=$(aws stepfunctions get-activity-task --worker-name ${jobflowid} --activity-arn ${ACTIVITY_ARN} --region "$AWS_DEFAULT_REGION")
payload=$(echo "$activity" | jq -r ".input")

#output
echo "$activity" > "/home/hadoop/activity_task.json"
echo "$payload" > "/home/hadoop/activity_task_payload.json"
