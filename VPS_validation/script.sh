#!/bin/bash

. /opt/app/workload/RPSScripts/sk742g/VPS_validation/config

>VPS_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>VPS URL's Status</h2>">>VPS_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>VPS_check.html

while read url;
do
        env=`echo $url | awk -F "/" '{print $3}' | awk -F "." '{print $1}'`
        /usr/bin/wget -q -S -O- $url --no-check-certificate > VPS_${env}.log 2>&1
        html=`grep HTTP VPS_${env}.log`
        msg=`grep CTN VPS_${env}.log | grep -v title`
        if [[ -n "${html}" ]]
        then
                if [[ `echo ${msg} | grep -i "View CTN Port Status"` ]]
                then
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>VPS_check.html
                else
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>VPS_check.html
                fi
        else
                msg="Unable to establish connection"
                html="NULL"
                printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>VPS_check.html
        fi
done</opt/app/workload/RPSScripts/sk742g/VPS_validation/VPS_URL

echo "</table></Body></html>">>VPS_check.html

rm *.log

(
echo "From: $SENDER"
echo "To: $RECEIVER"
echo "MIME-Version: 1.0"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
cat VPS_check.html
) | /usr/sbin/sendmail -t
