#!/bin/bash

version=0.102.4

repo_host="docker.artifactory.n.mes.corp.hmrc.gov.uk:80"
repo_path="eis-clamav"

docker build --network=host --build-arg VERSION=${version} -t ${repo_host}/${repo_path}:${version} .
