'use strict'

const AWS = require('aws-sdk');
const config = require("./config.json");
const emr = new AWS.EMR({ apiVersion: '2009-03-31' });

const emrConfig = Object.assign(config, {
  Steps: [
    {
      HadoopJarStep: {
        Jar: 'command-runner.jar',
        Args: ['ls','-la']
      },
      Name: 'Worker-Task',
      ActionOnFailure: "CONTINUE"
    },
    {
      HadoopJarStep: {
        Jar: 'command-runner.jar',
        Args: ['/home/hadoop/stepfunctions-scripts/send_task_status.sh','--activity','/home/hadoop/activity_task.json'],
      },
      Name: 'Activity-Status',
      ActionOnFailure: "CONTINUE"
    }
  ],
  BootstrapActions: [
    {
      Name: 'BoostrapStepFunctionActivity',
      ScriptBootstrapAction: {
        Path: process.env.EMR_BOOTSTRAP_SCRIPT,
        Args: ['-b',process.env.S3_BUCKET,'-a',process.env.ACTIVITY_ID]
      }
    }
  ],
})

exports.handler = (event, context, callback) => {
  emr.runJobFlow(config, function(err, data) {
    if (err) {
      callback(err);
    } else {
      const output = Object.assign({
        env: {
          activity_id: process.env.ACTIVITY_ID,
          s3_bucket: process.env.S3_BUCKET,
          emr_bootstrap_script: process.env.EMR_BOOTSTRAP_SCRIPT
        }
      }, data);
      callback(null, output);
    }
  });
};
