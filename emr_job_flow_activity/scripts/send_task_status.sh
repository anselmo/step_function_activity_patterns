!/bin/bash

#./stepfunctions-scripts/send_task_status.sh --activity activity_task.json

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -a|--activity)
      ACTIVITY="$2"
      shift
      shift
      ;;
      -s|--sequence)
      SEQUENCE="$2"
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

task_token=$(cat ${ACTIVITY} | jq -r ".taskToken")
total_steps=$(($(ls -l /mnt/var/lib/info/steps/* | grep -v ^l | wc -l)-1))
job_step_info=$(cat /mnt/var/lib/info/steps/${total_steps}.json)
state=$(echo $job_step_info | jq -r ".state")

echo ACTIVITY      = "${ACTIVITY}"
echo total_steps   = "$total_steps"
echo job_step_info = "$job_step_info"
echo state         = "$state"

if [ $state = 'FAILED' ]
then
output=$(aws stepfunctions send-task-failure --task-token "$task_token" --cause "$job_step_info" --region "$AWS_DEFAULT_REGION")
elif [ $state = 'COMPLETED' ]
then
output=$(aws stepfunctions send-task-success --task-token "$task_token" --task-output "$job_step_info" --region "$AWS_DEFAULT_REGION")
else
output=$(aws stepfunctions send-task-heartbeat --task-token "$task_token" --region "$AWS_DEFAULT_REGION")
fi

exit 0
