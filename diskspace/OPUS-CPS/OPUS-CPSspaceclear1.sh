#!/bin/bash

Homdir=/opt/app/workload/RPSScripts/sk742g/diskspace/OPUS-CPS
cd $Homdir
rm fin_space.log
rm fin_tmp.log

>space_clear.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2></h2>">>space_clear.html
echo "<table style='width:55%'><tr><th>Server</th><th>Final FileSpace</th><th>FileSpace Status</th><th>Message</th><th>Action Taken</th></tr>">>space_clear.html

for vtier in "$@"
do
/usr/local/bin/sshcmd -s $vtier -u $vtier << EOF >>fin_tmp.log
cd /opt/app/$vtier/logs/
curr_space=\$(df -kh | grep /opt/app | head -1 | awk '{ print \$4 }' | sed 's/%//g')
files=\$(find /opt/app/$vtier/logs/ -mtime +90 | wc -l)
if [[ \$files -eq 0 ]]
then
find /opt/app/$vtier/logs/ -type f -mtime +1 | grep -v .gz | grep -v .tar>>tmpfile.txt
if [ -s tmpfile.txt ]
then
while IFS= read -r file
do
gzip -f \$file
done < "tmpfile.txt"
rm tmpfile.txt
echo "action-$vtier :Compressed logs greater than 1 day"

elif [ ! -s tmpfile.txt ]
then
find /opt/app/$vtier/logs/ -mtime +30 -delete
echo "action-$vtier :Deleted logs greater than 30 days"
fi

elif [[ \$files -gt 0 ]]
then
find /opt/app/$vtier/logs/ -mtime +90 -delete
echo "action-$vtier :Deleted logs greater than 90 days"
fin_value=\$(df -kh | grep /opt/app | head -1 | awk '{ print \$4 }' | sed 's/%//g')
if [[ \$fin_value -ge 75 ]]
then
find /opt/app/$vtier/logs/ -type f -mtime +1 | grep -v .gz | grep -v .tar>>tmpfile.txt
if [ -s tmpfile.txt ]
then
while IFS= read -r file
do
gzip -f \$file
done < "tmpfile.txt"
rm tmpfile.txt
echo "action-$vtier :Compressed logs greater than 1 day"
fi
fi
fi
final_space=\$(df -kh | grep /opt/app | head -1 | awk '{ print \$4 }' | sed 's/%//g')
echo -e "Final_Space of $vtier\t\$final_space Current_space was \$curr_space"
EOF
done

cat fin_tmp.log | grep Final_Space >>fin_space.log


while read line
do
server_name=$(echo $line | awk '{ print $3 }')
final_space=$(echo $line | awk '{ print $4 }')
action=$(grep -o 'action-'$server_name'.*' fin_tmp.log | cut -f2- -d:)
Current_space=$(echo $line | awk '{ print $7 }')
if [[ $final_space -eq $Current_space ]]
then
msg="No logs greater than 1 day or 30 days found"
printf "<tr>
        <td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${final_space}</td>
        <td style='background-color:#00FF00'></td>
        <td style='background-color:#FFFFFF;text-align:center'>${msg}</td>
        <td style='background-color:#FFFFFF;text-align:center'></td>
        </tr>">>space_clear.html
elif [[ $final_space -ge 85 ]] && [[ $final_space -lt 90 ]]
then
msg="Look into the server"
printf "<tr>
        <td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${final_space}</td>
        <td style='background-color:#FFA500'></td>
        <td style='background-color:#FFFFFF;text-align:center'>${msg}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${action}</td>
        </tr>">>space_clear.html
elif [[ $final_space -ge 90 ]]
then
msg="High Risk.Look into the server"
printf "<tr>
        <td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${final_space}</td>
        <td style='background-color:#FF0000'></td>
        <td style='background-color:#FFFFFF;text-align:center'>${msg}</td>
        </tr>">>space_clear.html
else
msg="Filespace Good"
printf "<tr><td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${final_space}</td>
        <td style='background-color:#00FF00'></td>
        <td style='background-color:#FFFFFF;text-align:center'>${msg}</td>
        <td style='background-color:#FFFFFF;text-align:center'>${action}</td>
        </tr>">>space_clear.html
fi
done<fin_space.log

echo "</table></Body></html>">>space_clear.html

(
echo "From: sk742g@att.com"
echo "To: DL-OPUS-AlertMonitor@att.com"
echo "MIME-Version: 1.0"
echo "Subject: File system final status--OPUS-CPS"
echo "Content-Type: text/html"
cat space_clear.html
) | /usr/sbin/sendmail -t

