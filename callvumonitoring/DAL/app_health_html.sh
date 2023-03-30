#!/bin/bash

. /opt/app/workload/RPSScripts/sk742g/callvumonitoring/DAL/config

cd $LOG_DIR
rm *.log
cd $HOME_DIR

>IDS_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>CallVU IDS URL's Status</h2>">>IDS_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>IDS_check.html

while read url;
do
	env=`echo $url | awk '{print $2}'`
        URL=`echo $url | awk '{print $1}'`
	/usr/bin/wget -q -S -O- $URL --no-check-certificate > $LOG_DIR/IDS_${env}.log 2>&1
	html=`grep HTTP $LOG_DIR/IDS_${env}.log`
	msg=`grep CallVU $LOG_DIR/IDS_${env}.log`
	if [[ -n "${html}" ]]
	then
		if [[ `echo ${msg} | grep -i "WS_OK, DB_OK"` ]]
		then
			printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>IDS_check.html
		else
			printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDS_check.html
		fi
	else
		msg="Unable to establish connection"
		html="NULL"
		printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDS_check.html
	fi
done<$IDS_URL

echo "</table></Body></html>">>IDS_check.html



>IDS_Portal_url.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>CallVU IDS_Portal URL's Status</h2>">>IDS_Portal_url.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>IDS_Portal_url.html

while read IDS_Portal_url;
do
	env=`echo $IDS_Portal_url | awk '{print $2}'`
        URL=`echo $IDS_Portal_url | awk '{print $1}'`
        /usr/bin/wget -q -S -O- $URL --no-check-certificate > $LOG_DIR/IDS_Portal_${env}.log 2>&1
	html=`grep HTTP $LOG_DIR/IDS_Portal_${env}.log`
	msg=`grep CallVU $LOG_DIR/IDS_Portal_${env}.log`
        if [[ -n "${html}" ]]
        then
                if [[ `echo ${msg} | grep -i "WS_OK, DB_OK"` ]]
                then
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>IDS_Portal_url.html
                else
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDS_Portal_url.html
                fi
        else
                msg="Unable to establish connection"
                html="NULL"
                printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDS_Portal_url.html
        fi
done<$IDS_Portal_url


               
echo "</table></Body></html>">>IDS_Portal_url.html



>IDREG_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>CallVU IDREG URL's Status</h2>">>IDREG_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>IDREG_check.html

while read IDREG_url;
do
        env=`echo $IDREG_url | awk '{print $2}'`
        URL=`echo $IDREG_url | awk '{print $1}'`
        /usr/bin/wget -q -S -O- $URL --no-check-certificate > $LOG_DIR/IDREG_${env}.log 2>&1
        html=`grep HTTP $LOG_DIR/IDREG_${env}.log`
        msg=`grep CallVU $LOG_DIR/IDREG_${env}.log`
        if [[ -n "${html}" ]]
        then
                if [[ `echo ${msg} | grep -i "WS_OK, DB_OK"` ]]
                then
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>IDREG_check.html
                else
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDREG_check.html
                fi
        else
                msg="Unable to establish connection"
                html="NULL"
                printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>IDREG_check.html
        fi
done<$IDREG_url


echo "</table></Body></html>">>IDREG_check.html



>AttUtils_check.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>CallVU AttUtils URL's Status</h2>">>AttUtils_check.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>AttUtils_check.html

while read AttUtils_url;
do
        env=`echo $AttUtils_url | awk '{print $2}'`
        URL=`echo $AttUtils_url | awk '{print $1}'`
        /usr/bin/wget -q -S -O- $URL --no-check-certificate > $LOG_DIR/AttUtils_${env}.log 2>&1
        html=`grep HTTP $LOG_DIR/AttUtils_${env}.log`
        msg=`grep CallVU $LOG_DIR/AttUtils_${env}.log`
        if [[ -n "${html}" ]]
        then
                if [[ `echo ${msg} | grep -i "WS_OK"` ]]
                then
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>AttUtils_check.html
                else
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>AttUtils_check.html
                fi
        else
                msg="Unable to establish connection"
                html="NULL"
                printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>AttUtils_check.html
        fi
done<$AttUtils_url

echo "</table></Body></html>">>AttUtils_check.html

>Java_Internal.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>CallVU Java_Internal URL Status</h2>">>Java_Internal.html
echo "<table style='width:45%'><tr><th>Server</th><th>HTML Status</th><th>Message</th></tr>">>Java_Internal.html

while read Java_url;
do
       env=`echo $Java_url | awk '{print $2}'`
        URL=`echo $Java_url | awk '{print $1}'`
        /usr/bin/wget -q -S -O- $URL --no-check-certificate > $LOG_DIR/Java_${env}.log 2>&1
        html=`grep HTTP $LOG_DIR/Java_${env}.log`
        msg=`grep CallVU $LOG_DIR/Java_${env}.log`
        if [[ -n "${html}" ]]
        then
                if [[ `echo ${msg} | grep -i "OK"` ]]
                then
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#32CD32'>${msg}</td></tr>">>Java_Internal.html
                else
                        printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#FFFFFF'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>Java_Internal.html
                fi
        else
                msg="Unable to establish connection"
                html="NULL"
                printf "<tr><td style='background-color:#FFFFFF;font-weight:bold'>${env}</td><td style='background-color:#F81503'>${html}</td><td style='background-color:#F81503'>${msg}</td></tr>">>Java_Internal.html
        fi
done<$Java_url

echo "</table></Body></html>">>Java_Internal.html



(
echo "From: $SENDER"
echo "To: $RECEIVER"
echo "MIME-Version: 1.0"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
cat IDS_check.html
cat IDS_Portal_url.html
cat IDREG_check.html
cat AttUtils_check.html
cat Java_Internal.html
) | /usr/sbin/sendmail -t
