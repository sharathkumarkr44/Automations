#!/bin/ksh

file=$1
curr_date=$(date | awk '{print $2" "$3" "$6}')
failcount=0
cd /opt/app/workload/RPSScripts/sk742g/connectivity/TWL
rm success_result.html failed_result.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>OPUS TWLIGHT VM's Success Health Status</h2>">>success_result.html
echo "<table style='text-align:center'><tr><th>VM Name</th><th>Vtier</th><th>Connection Status</th></tr>">>success_result.html

echo "<html><head><style>table, th, td {border: 1px solid black; border-collapse: collapse;padding: 3px;}tr:nth-child(even) {background-color: #f2f2f2;}th {background-color: #283747;color: White;}</style></head><Body><h2>OPUS TWLIGHT VM's Failed Health Status</h2>">>failed_result.html
echo "<table style='text-align:center'><tr><th>VM Name</th><th>Vtier</th><th>Connection Status</th></tr>">>failed_result.html


while IFS= read -r i
do
VM=$(echo $i | awk '{print $1}')
vtier=$(echo $i | awk '{print $2}')
value=$(echo -e "^]\nclose" | telnet $VM 22 | grep Connected)

if [ ! -z "$value" ]
then
msg="Successfully Connected"
printf "<tr>
        <td style='font-weight:bold'>${VM}</td>
        <td style='font-weight:bold'>${vtier}</td>
        <td style='color:green'>${msg}</td>
        </tr>">>success_result.html
else
msg="NOT able to Connect"
failcount=$((failcount+1))
printf "<tr>
        <td style='font-weight:bold'>${VM}</td>
        <td style='font-weight:bold'>${vtier}</td>
        <td style='color:red'>${msg}</td>
        </tr>">>failed_result.html
fi
done < "$file" 

echo "</table></Body></html>">>success_result.html
echo "</table></Body></html>">>failed_result.html

#if [[ $failcount -gt 0 ]]
#then
(
echo "From: sk742g@att.com"
echo "To: sk742g@att.com"
echo "MIME-Version: 1.0"
echo "Subject: OPUS TWLIGHT VM's Connectivity Status for $curr_date"
echo "Content-Type: text/html"
cat failed_result.html
cat success_result.html
) | /usr/sbin/sendmail -t
#fi
