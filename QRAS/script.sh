#!/bin/bash

rm *.log

curr_date=$(date | awk '{print $2" "$3" "$6}')

>QRAS_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>QRAS URL's Status</h2>">>QRAS_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>Status</th></tr>">>QRAS_check.html

while read url;
do
env=`echo $url | awk -F "/" '{print $3}' | awk -F "." '{print $1}'`
/usr/bin/wget -q -S -O- $url --no-check-certificate > QRAS_"$env".log 2>&1
html=`grep "HTTP/1.1 200 OK" QRAS_"$env".log`
   if [[ `echo ${html} | grep -i "HTTP/1.1 200 OK"` ]]
                then
                printf "<tr><td style='background-color:#bababa;font-weight:bold'>${url}</td><td style='background-color:#32cd32'>${html}</td></tr>">>QRAS_check.html
   else
                html="Unable to establish connection"
                printf "<tr><td style='background-color:#bababa;font-weight:bold'>${url}</td><td style='background-color:#F81503'>${html}</td></tr>">>QRAS_check.html
fi
done</opt/app/workload/RPSScripts/sk742g/QRAS/QRAS_URL

url=qras-az-prod.att.net
URL=https://qras-az-prod.att.net/storeappointment/
echo -e "^]\nclose" | telnet $url 443 >>"$url".log
if [[ `grep -i "Connected to qras-az-prod.att.net." "$url".log` ]]
then
html="HTTP/1.1 200 OK"
printf "<tr><td style='background-color:#bababa;font-weight:bold'>${URL}</td><td style='background-color:#32cd32'>${html}</td></tr>">>QRAS_check.html
else
html="Unable to establish connection"
printf "<tr><td style='background-color:#bababa;font-weight:bold'>${URL}</td><td style='background-color:#F81503'>${html}</td></tr>">>QRAS_check.html
fi

echo "</table></Body></html>">>QRAS_check.html


(
echo "From: sk742g@att.com"
echo "To: DL-RPS-OPUS@att.com"
echo "MIME-Version: 1.0"
echo "Subject: QRAS Validation Status for $curr_date"
echo "Content-Type: text/html"
cat QRAS_check.html
) | /usr/sbin/sendmail -t
