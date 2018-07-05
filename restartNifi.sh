#!/bin/bash

port=<your nifi port>
logFile="<path to nifi Logs>/nifi-app.log"
restartLog=<set a path for this to log to>/restartNifi.log
netcount=`netstat -antp | grep ${port} | wc -l`
replicationFail=`tail -100 ${logFile} | grep "Failed to replicate request GET /nifi-api/site-to-site" | wc -l`

if [ ${netcount} -gt 1100 ]; then
  echo `date` ${netcount} restarting >> ${restartLog}
  systemctl restart nifi.service
else

badhost=`tail -100 ${logFile}| egrep -o '/nifi-api/site-to-site\sto\s([^:]+)'| awk '{print $3}' | sort -u`

for host in ${badhost}; do 
  if [ `grep ${host} /etc/hosts | awk '{print $2}'` == ${HOSTNAME} ]; then
    echo `date` replication fail ${replicationFail} restarting >> ${restartLog} #fix log message
    systemctl restart nifi.service
  fi
done
fi
