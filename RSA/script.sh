#!/bin/bash

rm *.log

curr_date=$(date | awk '{print $2" "$3" "$6}')

>RSA_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>RSA URL's Status</h2>">>RSA_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>Status</th></tr>">>RSA_check.html

while read url;
do
env=`echo $url | awk -F "/" '{print $3}' | awk -F "." '{print $1}'`
/usr/bin/wget -q -S -O- $url --no-check-certificate > RSA_"$env".log 2>&1
html=`grep "RSA Auth: Status OK" RSA_"$env".log`
   if [[ `echo ${html} | grep -i "RSA Auth: Status OK"` ]]
                then
                printf "<tr><td style='background-color:#bababa;font-weight:bold'>${url}</td><td style='background-color:#32cd32'>${html}</td></tr>">>RSA_check.html
   else
                html="Unable to establish connection"
                printf "<tr><td style='background-color:#bababa;font-weight:bold'>${url}</td><td style='background-color:#F81503'>${html}</td></tr>">>RSA_check.html
fi
done</opt/app/workload/RPSScripts/sk742g/RSA/RSA_urls

echo "</table></Body></html>">>RSA_check.html

(
echo "From: sk742g@att.com"
echo "To: DL-RPS-OPUS@att.com"
echo "MIME-Version: 1.0"
echo "Subject: RSA Validation Status for $curr_date"
echo "Content-Type: text/html"
cat RSA_check.html
) | /usr/sbin/sendmail -t
