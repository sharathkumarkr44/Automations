
#!/bin/bash

Homdir=/opt/app/workload/RPSScripts/sk742g/diskspace/SSK
rm space.log 

>space_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2></h2>">>space_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>Current FileSpace</th><th>FileSpace Status</th></tr>">>space_check.html

for podname in "$@"
do
for i in 01 02 03
do
/usr/local/bin/sshcmd -s $podname$i -u $podname$i << EOF >>tmp.log
cd logs
value=\$(df -kh | grep /opt/app | head -1 | awk '{ print \$4 }' | sed 's/%//g')
if [[ \$value -ge 80 ]]
then
echo -e "$podname$i\t\$value"
fi
EOF
done
done

cat tmp.log | grep -v login | grep -v Logging >>space.log
rm tmp.log
if [[ -s space.log ]]
then
while read line
do
server_name=$(echo $line | awk '{ print $1 }')
curr_space=$(echo $line | awk '{ print $2 }')
if [[ $curr_space -ge 80 ]] && [[ $curr_space -lt 85 ]]
then
printf "<tr><td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td><td style='background-color:#FFFFFF;text-align:center'>${curr_space}</td><td style='background-color:#FFFF00'></td></tr>">>space_check.html
elif [[ $curr_space -ge 85 ]] && [[ $curr_space -lt 90 ]]
then
printf "<tr><td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td><td style='background-color:#FFFFFF;text-align:center'>${curr_space}</td><td style='background-color:#FFA500'></td></tr>">>space_check.html
elif [[ $curr_space -ge 90 ]]
then
printf "<tr><td style='background-color:#FFFFFF;font-weight:bold;text-align:center'>${server_name}</td><td style='background-color:#FFFFFF;text-align:center'>${curr_space}</td><td style='background-color:#FF0000'></td></tr>">>space_check.html
fi
done<space.log

elif [[ ! -s space.log ]]
then
printf "Hi team,\n\n All servers filespace is well before the threshold. " | mail -s "File system space GREEN--SSK" -r "sk742g@att.com" sk742g@att.com gv254h@att.com

exit
fi

echo "</table></Body></html>">>space_check.html

(
echo "From: sk742g@att.com"
echo "To: sk742g@att.com gv254h@att.com"
echo "MIME-Version: 1.0"
echo "Subject: File system space alerts--SSK"
echo "Content-Type: text/html"
cat space_check.html
) | /usr/sbin/sendmail -t

cd $Homdir
./SSKspaceclear.sh $(cat space.log | awk '{ print $1 }')
