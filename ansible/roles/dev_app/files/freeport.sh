#!/bin/bash

INCREMENT=1

port=9000 # get random comfortable port number since you start open on server
isfree=$(netstat -taln | grep $port)

while [[ $cnt -lt 100 ]]
do
BASE_PORT=$[port+INCREMENT]
port=$BASE_PORT
isfree=$(netstat -taln | grep $port)
while [[ -n "$isfree" ]]; do
    port=$[port+INCREMENT]
    isfree=$(netstat -taln | grep $port)
done
echo "$port"
cnt=$(( $cnt + 1 ))
 if [[ $cnt -gt 100 ]] ; then
    break
 fi
done | bc -l