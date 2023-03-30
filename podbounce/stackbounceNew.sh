#!/bin/bash

web_stop () {
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $web_server"
./stopApache.sh
EOF
echo "------------------------------------------------------------------------------------"
}

FE_stop () {
/usr/local/bin/sshcmd -s $FE_server -u $FE_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $FE_server"
./killManagedServer.sh
echo "Backing up logs on $FE_server"
./k80backuplogs
EOF
echo "------------------------------------------------------------------------------------"
}

BE_stop () {
/usr/local/bin/sshcmd -s $BE_server -u $BE_server 2>/dev/null<<EOF
cd shutdown
echo "shutting down $BE_server"
./killManagedServer.sh
echo "Backing up logs on $BE_server"
./k80backuplogs
EOF
echo "------------------------------------------------------------------------------------"
}

BE_start () {
/usr/local/bin/sshcmd -s $BE_server -u $BE_server 2>/dev/null<<EOF
cd startup
echo "starting up $BE_server"
./s70mgdweblogic
EOF
echo "------------------------------------------------------------------------------------"
}

BE_Check () {
/usr/local/bin/sshcmd -s $BE_server -u $BE_server 2>/dev/null<<EOF
echo "Checking $BE_server status ...."
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
./s70mgdweblogic
EOF
echo "------------------------------------------------------------------------------------"
}

FE_Check () {
/usr/local/bin/sshcmd -s $FE_server -u $FE_server 2>/dev/null<<EOF
echo "Checking $FE_server status ...."
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
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF 
cd startup
echo "starting up $web_server"
./startApache.sh opusapachekey
sleep 20s
EOF
echo "------------------------------------------------------------------------------------"
}

test_connection () {
/usr/local/bin/sshcmd -s $web_server -u $web_server 2>/dev/null<<EOF >>"$web_server".log
cd /opt/app/$web_server/logs
tail access
EOF
cat "$web_server".log
echo "------------------------------------------------------------------------------------"
rm "$web_server".log
}


for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
                web_server=${pod}w${stack}
                web_stop
done


for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
                FE_server=${pod}f${stack}
                FE_stop
done


for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
                BE_server=${pod}b${stack}
                BE_stop
done

sleep 20s

for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
               BE_server=${pod}b${stack}
               BE_start
done

sleep 1m

for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
               BE_server=${pod}b${stack}
               BE_Check
done

for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
              FE_server=${pod}f${stack}
              FE_start
done

sleep 1m

for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
              FE_server=${pod}f${stack}
              FE_Check
done

for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
              web_server=${pod}w${stack}       
              web_start
done


for vtier in $@
do
 pod=$(echo $vtier | cut -c 1-5)
 stack=$(echo $vtier | cut -c 7,8)
              web_server=${pod}w${stack}
              test_connection
done
