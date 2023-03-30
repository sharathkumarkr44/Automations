#!/bin/bash
 

be_connect () {
/usr/local/bin/sshcmd -s $b_server -u $b_server 2>/dev/null<<EOF >> result
proc_details=\$(ps -ef | grep $b_server | grep server | grep -v grep)
if [[ -z "\${proc_details}" ]]
then
echo "$b_server NOT RUNNING"
fi
EOF
}

fe_connect () {
/usr/local/bin/sshcmd -s $f_server -u $f_server 2>/dev/null<<EOF >> result
proc_details=\$(ps -ef | grep $f_server | grep server | grep -v grep)
if [[ -z "\${proc_details}" ]]
then
echo "$f_server NOT RUNNING"
fi
EOF
}

web_connect () {
url="https://$w_server.vci.att.com:8443/opus/security/TestSystemHealth.jsp"
/usr/bin/wget -q -S -O- $url --no-check-certificate > web.log 2>&1
http_code=$(grep HTTP web.log | awk '{print $2}')
if [[ $http_code -eq "0" ]]
then
echo "$w_server NOT RUNNING" >> result
fi
}

rm result

for POD in "$@"
do
        num=1
        while [ ${num} -lt 10 ]
        do
        slice=0
        b_server=${POD}b${slice}${num}
        be_connect
        f_server=${POD}f${slice}${num}
        fe_connect
        w_server=${POD}w${slice}${num}
        web_connect
        num=`expr $num + 1`
        done
        numb=10
        while [ $numb -lt 13 ]
        do
        b_server=${POD}b${numb}
        be_connect
        f_server=${POD}f${numb}
        fe_connect
        w_server=${POD}w${numb}
        web_connect
        numb=`expr $numb + 1`
        done
done

cat result | grep -e NOT -e Didnt
