#!/usr/bin/env bash

set -e

envLocation="../../.env.production"

#format the .env file into a list like "ENV1=foo,ENV2=bar,ENV3=bas"
#strip empty lines, replace newlines with commas, delete last comma
formattedEnv=$(grep -v '^[[:space:]]*$' ${envLocation} | grep -E -v '^[^=;]+=$' | tr '\n' ',' |  sed 's/,\s*$//')

#updating env requires deploying a new revision
gcloud beta run services update laravel-cloud-run --update-env-vars ${formattedEnv} \
  --platform managed --project wonderkind-testing --region europe-west1 --memory 512Mi
