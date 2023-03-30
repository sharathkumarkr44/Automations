#!/bin/bash

. /opt/app/workload/RPSScripts/sk742g/UPTIME/insys_servers.txt
rm uptime.html

for POD in $@
do
echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>UPTIME STATUS FOR $POD</h2>">>uptime.html
echo "<table style='width:45%'><tr><th>Server</th><th>Host</th><th>Uptime</th></tr>">>uptime.html

for (( num=1; num<10; num++ ))
do
slice=0
web_server=${POD}w${slice}${num}
uptime=$(sshcmd -u $web_server -s $web_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
FE_server=${POD}f${slice}${num}
uptime=$(sshcmd -u $FE_server -s $FE_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
BE_server=${POD}b${slice}${num}
uptime=$(sshcmd -u $BE_server -s $BE_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
done

for (( num=10; num<=12; num++ ))
do
web_server=${POD}w${num}
uptime=$(sshcmd -u $web_server -s $web_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
FE_server=${POD}f${num}
uptime=$(sshcmd -u $FE_server -s $FE_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
BE_server=${POD}b${num}
uptime=$(sshcmd -u $BE_server -s $BE_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
done

for (( num=1; num<=4; num++ ))
do
slice=0
cache_server=${POD}c${slice}${num}
uptime=$(sshcmd -u $cache_server -s $cache_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
done

resend_server=${POD}r01
uptime=$(sshcmd -u $resend_server -s $resend_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt

#insys part here------>
stack=$(echo $POD | cut -c 4,5)
dc=$(echo $POD | cut -c 3)
for num in 1 2
do
insys_server=pob${stack}i${dc}${num}
if [[ `grep -i ${insys_server} /opt/app/workload/RPSScripts/sk742g/UPTIME/insys_servers.txt` ]]
then 
uptime=$(sshcmd -u $insys_server -s $insys_server "uptime | awk '{print \$3,\$4}'")
echo $uptime | awk -F "," '{print $1}' | awk '{print $4,$5,$6}' >>uptime.txt
fi
done

sort -k 2n uptime.txt | grep -v day >>uptimefinal.txt
sort -k 2n uptime.txt | grep day >>uptimefinal.txt
rm uptime.txt
cat uptimefinal.txt

while IFS= read -r line
do
server=$(echo $line | awk '{print $1}')
uptime=$(echo $line | awk '{print $2,$3}')
host=$(nslookup $server | grep canonical | awk -F "=" '{print $2}')
if [[ -n "${uptime}" ]]
then
  if [[ `echo ${uptime} | grep -i "day"` ]]
     then
     printf "<tr>
             <td style='font-weight:bold;text-align:center'>${server}</td>
             <td style='font-weight:bold;text-align:center'>${host}</td>
             <td style='font-weight:bold;text-align:center'>${uptime}</td>
             </tr>">>uptime.html
  else
     printf "<tr>
             <td style='font-weight:bold;text-align:center'>${server}</td>
             <td style='font-weight:bold;text-align:center'>${host}</td>
             <td style='font-weight:bold;background-color:#FFFF00;text-align:center'>${uptime}</td>
             </tr>">>uptime.html
  fi
else
uptime="Unable to establish connection"
printf "<tr>
        <td style='font-weight:bold'>${server}</td>
        <td style='font-weight:bold'>${host}</td>
        <td style='font-weight:bold'>${uptime}</td>
        </tr>">>uptime.html
fi
done < uptimefinal.txt
rm uptimefinal.txt

echo "</table></Body></html>">>uptime.html
done

(
echo "From: sk742g@att.com"
echo "To: sk742g@att.com"
echo "MIME-Version: 1.0"
echo "Subject: UPTIME status for $@"
echo "Content-Type: text/html"
cat uptime.html
) | /usr/sbin/sendmail -t
