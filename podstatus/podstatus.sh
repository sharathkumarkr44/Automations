#!/bin/ksh

. /opt/app/workload/RPSScripts/sk742g/podstatus/config

connect () {
/usr/local/bin/sshcmd -s $server -u $server 2>/dev/null<<EOF >> result
cd logs
log_details=\$(grep -h "Server state changed to RUNNING" weblogic-server.log* | awk -F">" '{print \$1}' | sed 's/[][#<>,]//g' | awk '{print \$1" "\$2" "\$3}')
current_date=\$(date | awk '{print \$2" "\$3" "\$6}')
if [[ "\${log_details}" = "\${current_date}" ]]
then
echo "$server RUNNING Yes"
elif [[ -z "\${log_details}" ]]
then
echo "$server Unknown Unknown"
else
echo "$server RUNNING \${log_details}"
fi
EOF
}

cd $LOG_DIR
rm *.log
cd $HOME_DIR
rm result success_result.html failed_result.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>OPUS DAL POD's Success Health Status</h2>">>success_result.html
echo "<table style='text-align:center'><tr><th>BE Server</th><th>BE Status</th><th>BE<br> Rebooted<br> Today</th><th>FE Server</th><th>FE Status</th><th>FE<br> Rebooted<br> Today</th><th>Web Server</th><th>Web Health check JSP<br>HTTP Status</th><th>Web Health check JSP Response</th></tr>">>success_result.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>OPUS DAL POD's Failed Health Status</h2>">>failed_result.html
echo "<table style='text-align:center'><tr><th>BE Server</th><th>BE Status</th><th>BE<br> Rebooted<br> Today</th><th>FE Server</th><th>FE Status</th><th>FE<br> Rebooted<br> Today</th><th>Web Server</th><th>Web Health check JSP<br>HTTP Status</th><th>Web Health check JSP Response</th></tr>">>failed_result.html

for POD in $@
do
	num=1
	while [ ${num} -lt 10 ]
	do
		slice=0
		server=${POD}b${slice}${num}
		connect
		b_server=$server
		b_status=`grep $server result | grep -v Logging | awk '{print $2}'` 
		b_rebooted=`grep $server result | grep -v Logging | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`
		server=${POD}f${slice}${num}
		connect
		f_server=$server
		f_status=`grep $server result | grep -v Logging | awk '{print $2}'`
		f_rebooted=`grep $server result | grep -v Logging | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`
		server=${POD}w${slice}${num}
		w_server=$server
		url="https://$server.vci.att.com:8443/opus/security/TestSystemHealth.jsp"
		/usr/bin/wget -q -S -O- $url --no-check-certificate > $LOG_DIR/$server.log 2>&1
                http=`grep HTTP $LOG_DIR/$server.log`
		http_code=$(grep HTTP $LOG_DIR/$server.log | awk '{print $2}')
                msg=`grep Backend $LOG_DIR/$server.log |  sed -e 's/<[^>]*>//g'`
		if [[ $b_rebooted = "Yes" ]] && [[ $f_rebooted = "Yes" ]] && [[ $http_code -eq 200 ]]
		then
		printf "<tr>
			<td style='font-weight:bold'>${b_server}</td>
			<td style='color:green'>${b_status}</td>
			<td style='color:green'>${b_rebooted}</td>
			<td style='font-weight:bold'>${f_server}</td>
			<td style='color:green'>${f_status}</td>
			<td style='color:green'>${f_rebooted}</td>
			<td style='font-weight:bold'>${w_server}</td>
			<td style='color:green'>${http}</td>
			<td style='color:green'>${msg}</td>
			</tr>">>success_result.html
		elif [[ $b_status = "Unknown" ]] || [[ $f_status = "Unknown" ]] || [[ $http_code -ne 200 ]]
		then
		printf "<tr>
			<td style='font-weight:bold'>${b_server}</td>
			<td style='color:red'>${b_status}</td>
			<td style='color:red'>${b_rebooted}</td>
			<td style='font-weight:bold'>${f_server}</td>
			<td style='color:red'>${f_status}</td>
			<td style='color:red'>${f_rebooted}</td>
			<td style='font-weight:bold'>${w_server}</td>
			<td style='color:red'>${http}</td>
			<td style='color:red'>${msg}</td>
			</tr>">>failed_result.html
		elif [[ $b_rebooted != "Yes" ]] || [[ $f_rebooted != "Yes" ]]
		then
		printf "<tr>
                        <td style='font-weight:bold'>${b_server}</td>
                        <td style='color:green'>${b_status}</td>
                        <td style='color:red'>${b_rebooted}</td>
                        <td style='font-weight:bold'>${f_server}</td>
                        <td style='color:green'>${f_status}</td>
                        <td style='color:red'>${f_rebooted}</td>
                        <td style='font-weight:bold'>${w_server}</td>
                        <td style='color:green'>${http}</td>
                        <td style='color:green'>${msg}</td>
                        </tr>">>failed_result.html
		fi
		num=`expr $num + 1`
	done
	numb=10
	while [ $numb -lt 13 ]
	do
        	server=${POD}b${numb}
        	connect
                b_server=$server
                b_status=`grep $server result | grep -v Logging | awk '{print $2}'`
                b_rebooted=`grep $server result | grep -v Logging | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`
        	server=${POD}f${numb}
        	connect
                f_server=$server
                f_status=`grep $server result | grep -v Logging | awk '{print $2}'`
                f_rebooted=`grep $server result | grep -v Logging | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`
                server=${POD}w${numb}
		w_server=$server
                url="https://$server.vci.att.com:8443/opus/security/TestSystemHealth.jsp"
                /usr/bin/wget -q -S -O- $url --no-check-certificate > $LOG_DIR/$server.log 2>&1
                http=`grep HTTP $LOG_DIR/$server.log`
		http_code=$(grep HTTP $LOG_DIR/$server.log | awk '{print $2}')
                msg=`grep Successfuly $LOG_DIR/$server.log |  sed -e 's/<[^>]*>//g'`
                if [[ $b_rebooted = "Yes" ]] && [[ $f_rebooted = "Yes" ]] && [[ $http_code -eq 200 ]]
                then
                printf "<tr>
                        <td style='font-weight:bold'>${b_server}</td>
                        <td style='color:green'>${b_status}</td>
                        <td style='color:green'>${b_rebooted}</td>
                        <td style='font-weight:bold'>${f_server}</td>
                        <td style='color:green'>${f_status}</td>
                        <td style='color:green'>${f_rebooted}</td>
                        <td style='font-weight:bold'>${w_server}</td>
                        <td style='color:green'>${http}</td>
                        <td style='color:green'>${msg}</td>
                        </tr>">>success_result.html
                elif [[ $b_status = "Unknown" ]] || [[ $f_status = "Unknown" ]] || [[ $http_code -ne 200 ]]
                then
                printf "<tr>
                        <td style='font-weight:bold'>${b_server}</td>
                        <td style='color:red'>${b_status}</td>
                        <td style='color:red'>${b_rebooted}</td>
                        <td style='font-weight:bold'>${f_server}</td>
                        <td style='color:red'>${f_status}</td>
                        <td style='color:red'>${f_rebooted}</td>
                        <td style='font-weight:bold'>${w_server}</td>
                        <td style='color:red'>${http}</td>
                        <td style='color:red'>${msg}</td>
                        </tr>">>failed_result.html
                elif [[ $b_rebooted != "Yes" ]] || [[ $f_rebooted != "Yes" ]]
                then
                printf "<tr>
                        <td style='font-weight:bold'>${b_server}</td>
                        <td style='color:green'>${b_status}</td>
                        <td style='color:red'>${b_rebooted}</td>
                        <td style='font-weight:bold'>${f_server}</td>
                        <td style='color:green'>${f_status}</td>
                        <td style='color:red'>${f_rebooted}</td>
                        <td style='font-weight:bold'>${w_server}</td>
                        <td style='color:green'>${http}</td>
                        <td style='color:green'>${msg}</td>
                        </tr>">>failed_result.html
                fi
        	numb=`expr $numb + 1`
	done
done

echo "</table></Body></html>">>success_result.html
echo "</table></Body></html>">>failed_result.html
echo "Please Check the mail for status of $@"
#cat result | grep -v Logging

(
echo "From: $SENDER"
echo "To: $RECEIVER"
echo "MIME-Version: 1.0"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
cat failed_result.html
cat success_result.html
) | /usr/sbin/sendmail -t
