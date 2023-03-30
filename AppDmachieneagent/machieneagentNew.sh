#!/bin/bash

curr_date=$(date | awk '{print $1" "$2" "$3" "$6}')
rm tmp.log norestart.txt
for podname in "$@"
do
for i in 01 02 03 04 05 06 07 08 09 10 11 12
do
/usr/local/bin/sshcmd -s $podname$i -u $podname$i << EOF >>tmp.log
process_date=\$(ps -eo lstart,cmd | grep machine | grep -v grep | awk '{print \$1" "\$2" "\$3" "\$5}')
if [ \$process_date != \$curr_date ]
then
echo "AppD-Machiene agent is NOT restarted on $podname$i"
fi
EOF
done
done
cat tmp.log | grep "AppD-Machiene agent" >> norestart.txt
if [ -s norestart.txt ]
then
cat gen.txt "norestart.txt" fin.txt | mail -s "AppD Machine Agent frontend and backend status report for $curr_date" -a "norestart.txt" -r "sk742g@att.com" DL-RPS-OPUS@att.com
fi 
