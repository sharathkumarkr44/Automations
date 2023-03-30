#!/bin/bash

web_stop () {
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $web_server"
ls stopApache.sh
EOF
echo "------------------------------------------------------------------------------------"
}

FE_stop () {
/usr/local/bin/sshcmd -s $FE_server -u $FE_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $FE_server"
ls killManagedServer.sh
echo "Backing up logs on $FE_server"
ls k80backuplogs
EOF
echo "------------------------------------------------------------------------------------"
}

BE_stop () {
/usr/local/bin/sshcmd -s $BE_server -u $BE_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $BE_server"
ls killManagedServer.sh
echo "Backing up logs on $BE_server"
ls k80backuplogs
EOF
echo "------------------------------------------------------------------------------------"
}

BE_start () {
/usr/local/bin/sshcmd -s $BE_server -u $BE_server 2>/dev/null<<EOF
cd startup
echo "starting up $BE_server"
ls s70mgdweblogic
sleep 1m
cd /opt/app/$BE_server/logs
grep RUNNING weblogic-server.log>tmp.log
if [ -s tmp.log ]
then 
rm tmp.log
exit
else
sleep 1m
grep RUNNING weblogic-server.log>tmp.log
if [ -s tmp.log ]
then
rm tmp.log
exit
fi
fi
EOF
echo "------------------------------------------------------------------------------------"
}

FE_start () {
/usr/local/bin/sshcmd -s $FE_server -u $FE_server 2>/dev/null<<EOF
cd startup
echo "starting up $FE_server"
ls s70mgdweblogic
sleep 1m
cd /opt/app/$FE_server/logs
grep RUNNING weblogic-server.log>tmp.log
if [ -s tmp.log ]
then
rm tmp.log
exit
else
sleep 1m
grep RUNNING weblogic-server.log>tmp.log
if [ -s tmp.log ]
then
rm tmp.log
exit
fi
fi
EOF
echo "------------------------------------------------------------------------------------"
}

web_start () {
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF >>connection-status.log
cd startup
echo "starting up $web_server"
ls startapache.sh
sleep 10s
EOF
}

test_connection () {
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF >>connection-status.log
cd /opt/app/$web_server/logs
tail access
EOF
echo "------------------------------------------------------------------------------------"
cat connection-status.log
echo "------------------------------------------------------------------------------------"
rm connection-status.log
}


for POD in $@
do
        num=1
        while [ ${num} -lt 10 ]
        do
                slice=0
               web_server=${POD}w${slice}${num}
               web_stop
               FE_server=${POD}f${slice}${num}
               FE_stop
               BE_server=${POD}b${slice}${num}
               BE_stop
               sleep 20s
               BE_start
               FE_start
               web_start
               test_connection
               num=$((num+1))
        done
      
         numb=10
        while [ $numb -lt 13 ]
        do
                web_server=${POD}w${num}
                web_stop
                FE_server=${POD}f${num}
                FE_stop
                BE_server=${POD}b${num}
                BE_stop
                sleep 20s
                BE_start
                FE_start
                web_start
                test_connection
                numb=$((numb+1))
        done
done     
               



