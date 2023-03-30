#!/bin/bash

Cache_start () {
/usr/local/bin/sshcmd -s $cache_server -u $cache_server 2>/dev/null<<EOF >> cache_result
                proc_details=\$(ps -ef | grep $cache_server | grep server | grep -v grep)
                if [[ -z "\${proc_details}" ]]
                then
                echo "$cache_server was NOT RUNNING"
                cd startup
                ./s70mgdweblogic
                echo "$cache_server was Started"
                else
                echo "$cache_server is in RUNNING STATE"
                fi
EOF
}


Insys_start () {
/usr/local/bin/sshcmd -s $insys_server -u $insys_server 2>/dev/null<<EOF >> insys_result
                proc_details=\$(ps -ef | grep $insys_server | grep server | grep -v grep)
                if [[ -z "\${proc_details}" ]]
                then
                echo "$insys_server was NOT RUNNING"
                cd startup
                ./s70mgdweblogic
                echo "$insys_server was Started"
                else
                echo "$insys_server is in RUNNING STATE"
                fi
EOF
}


Resend_start () {
/usr/local/bin/sshcmd -s $resend_server -u $resend_server 2>/dev/null<<EOF >> resend_result
                proc_details=\$(ps -ef | grep $resend_server | grep server | grep -v grep)
                if [[ -z "\${proc_details}" ]]
                then
                echo "$resend_server was NOT RUNNING"
                cd startup
                ./s50weblogic
                echo "$resend_server was Started"
                else
                echo "$resend_server is in RUNNING STATE"
                fi
EOF
}


for POD in $@
do
num=1
while [ ${num} -le 4 ]
do
                slice=0
                cache_server=${POD}c${slice}${num}
                Cache_start
                num=$((num+1))
done
done

for POD in $@
do
no=1
stack=$(echo $POD | cut -c 4,5)
dc=$(echo $POD | cut -c 3)
while [ ${no} -le 2 ]
do
               insys_server=pob${stack}i${dc}${no}
               Insys_start
               no=$((no+1))
done
done

for POD in $@
do
               resend_server=${POD}r01
               Resend_start
done




echo "--------------------------------------------------------CACHE-STATUS--------------------------------------------------------------"
cat cache_result | grep -e was -e is | grep -v server
echo "--------------------------------------------------------INSYS-STATUS--------------------------------------------------------------"
cat insys_result | grep -e was -e is | grep -v server
echo "--------------------------------------------------------RESEND_STATUS--------------------------------------------------------------"
cat resend_result | grep -e was -e is | grep -v server


rm cache_result
rm insys_result
rm resend_result
