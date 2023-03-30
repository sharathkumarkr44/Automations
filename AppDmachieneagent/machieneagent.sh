#!/bin/bash

curr_date=$(date | awk '{print $2" "$3" "$6}')
rm tmp.log NoMachieneagent.txt MultipleMachieneagentPID.txt
for podname in "$@"
do
for i in 01 02 03 04 05 06 07 08 09 10 11 12
do
/usr/local/bin/sshcmd -s $podname$i -u $podname$i << EOF >>tmp.log
process_count=\$(ps -ef --sort=start_time | grep $podname$i | grep MachineAgent | grep -v 00:00:00 | wc -l)

if [ \$process_count -gt 1 ]
then
for (( j=1; j < \$process_count; j++ ))
do
pid=\$(ps -ef --sort=start_time | grep $podname$i | grep MachineAgent | grep -v 00:00:00 | sed -n "\$j"p | awk '{print \$2}')
echo \$pid for $podname$i
#kill -9 \$pid 
done
else
echo "Only 1 AppD-Machiene agent Runnning on $podname$i"
fi

if [ \$process_count -lt 1 ]
then
echo "No AppD-Machiene agent Runnning on $podname$i"
fi
EOF
done
done
cat tmp.log | grep "for" >>MultipleMachieneagentPID.txt
cat tmp.log | grep "No AppD-Machiene agent" >>NoMachieneagent.txt
if [ -s MultipleMachieneagentPID.txt ] || [ -s NoMachieneagent.txt ]
then
printf "Hi team, \n\nPlease find the AppD Machine agent status files. \n\n\n\n\nNoMachieneagent.txt - Servers on which No Machieneagent process running. \nMultipleMachieneagentPID.txt - Servers on which Multiple Machieneagent process running.\n\n\n\n\nNote: This is autogenerated mail" | mail -s "AppD Machine Agent frontend and backend status report for $curr_date" -a "MultipleMachieneagentPID.txt" -a "NoMachieneagent.txt" -r "sk742g@att.com" DL-RPS-OPUS@att.com
fi 
