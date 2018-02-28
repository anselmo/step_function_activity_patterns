#!/bin/bash

# EMR StepFunctions Activity Bootstrap

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
      -b|--bucket)
      S3BUCKET="$2"
      shift
      shift
      ;;
      -a|--activity)
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

echo S3BUCKET     = "${S3BUCKET}"
echo ACTIVITY_ARN = "$ACTIVITY_ARN"

scripts_home=/home/hadoop/stepfunctions-scripts
mkdir "$scripts_home"
aws s3 sync $S3BUCKET $scripts_home
chmod 755 "$scripts_home"/*.sh

/home/hadoop/stepfunctions-scripts/get_activity_task.sh --activity-arn "$ACTIVITY_ARN"

exit 0
