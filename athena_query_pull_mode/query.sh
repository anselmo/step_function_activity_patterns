#!/bin/bash

input='{"query":"SELECT * FROM \"bookings\".\"dbsample\" limit 10;","outputLocation":"s3://aws-"}'
aws stepfunctions start-execution --state-machine-arn <state-machine-arn> --input "$input"
