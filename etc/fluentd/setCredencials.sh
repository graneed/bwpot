#!/bin/bash
set -Ceu

cd `dirname $0`

source ./credencials

sed -i "s|project .*|project ${BIGQUERY_PROJECT}|" ../../docker/fluentd/dist/fluent.conf
sed -i "s|dataset .*|dataset ${BIGQUERY_TABLESET}|" ../../docker/fluentd/dist/fluent.conf
