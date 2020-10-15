#!/bin/bash
APP='autoheal'
image_name=$1
echo $image_name;
docker run -d --name container_test $image_name;
sleep 1;
waiting=1;
att=0;

echo "#### Waiting to launch ${APP} container ####"
echo false > healthy.txt;
    while [[ $waiting -eq 1 && $att -le 60 ]]; do response=`docker inspect -f {{.State.Health.Status}} container_test`;
     if  [[  $response == "starting" ]]; then
      echo "Waiting for ${APP} Container to start"
     elif [[ $response == "healthy" ]]; then
      echo true > healthy.txt;
      echo "${APP} Container is healthy"
      waiting="0";
     elif [[ $response == "unhealthy" ]]; then
       docker logs container_test
       echo "${APP} Container is unhealthy"
       echo false > healthy.txt;
       waiting="0";
     else
       echo "Something else happened...";
       echo false > healthy.txt;
       waiting="0";
     fi
     ((att=att+1))
     sleep 10;
    done
echo "#### Stopping and Removing the test container###"
docker container stop container_test;
