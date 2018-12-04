#!/bin/bash

PROJECT_NAME='airflow'

# Create the base-container project that contains the images
oadm new-project $PROJECT_NAME --display-name=$PROJECT_NAME --description='Apache Airflow on OpenShift'

oc create -f deployments/airflow-secrets.yaml -n $PROJECT_NAME
oc create -f deployments/airflow-pv.yaml -n $PROJECT_NAME

oc create -f deployments/airflow-build.yaml -n $PROJECT_NAME

oc create -f deployments/airflow-database.yaml -n $PROJECT_NAME

oc create -f deployments/airflow-deploy-webserver.yaml -n $PROJECT_NAME
oc create -f deployments/airflow-deploy-scheduler.yaml -n $PROJECT_NAME