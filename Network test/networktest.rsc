# Installs networktest.script for RouterOS
#
# You can set default values of variables here
# before import this file with
# /import file=networktest.rsc
#

:global NwTestServer "50.235.23.218"
:global NwTestUser "btest"
:global NwTestPass "btest"

:global NwTestEmail "your@email.address"
:global NwTestSmtp "smtp.your.domain"

:global NwTestRuninterval "01:00:00"

#
# Don't modify anything below this line!!!
###############################################################################
/system script
add name=networktest owner=admin policy=read,test source="####################\
    ########################################################\r\
    \n#\r\
    \n# Testing network bandwidth and ping time and sending results in e-mail\
    \r\
    \n#\r\
    \n# Set your server and e-mail parameters before use!!!\r\
    \n#\r\
    \n# You can run it periodically from scheduler, like this:\r\
    \n# /system scheduler add name=NetTest_hourly interval=1h start-time=start\
    up \\\r\
    \n# on-event=\"/system script run networktest\" policy=read,test\r\
    \n#\r\
    \n########################################################################\
    ####\r\
    \n\r\
    \n## Test server parameters\r\
    \n:local server \"$NwTestServer\"\r\
    \n:local user \"$NwTestUser\"\r\
    \n:local password \"$NwTestPass\"\r\
    \n\r\
    \n## E-mail parameters\r\
    \n:local email \"$NwTestEmail\"\r\
    \n:local smtp \"$NwTestSmtp\"\r\
    \n\r\
    \n## Some test parameters\r\
    \n:local protocol \"udp\"\r\
    \n:local duration \"10s\"\r\
    \n:local pingcount \"5\"\r\
    \n\r\
    \n########################################################################\
    ####\r\
    \n# Don't change anything below this line!\r\
    \n\r\
    \n:local rxta\r\
    \n:local rxtaA\r\
    \n:local rxtaB\r\
    \n:local rxtaC\r\
    \n\r\
    \n:local txta\r\
    \n:local txtaA\r\
    \n:local txtaB\r\
    \n:local txtaC\r\
    \n\r\
    \n:local avgRtt\r\
    \n:local pin\r\
    \n:local pout\r\
    \n\r\
    \n# Get system time and identity\r\
    \n:local sysname [/system identity get name]\r\
    \n:local datetime \"\$[/system clock get date] \$[/system clock get time]\
    \"\r\
    \n\r\
    \n:log info \"Network-test start\"\r\
    \n\r\
    \n# Ping test\r\
    \n/tool flood-ping address=\$server count=\$pingcount do={\r\
    \n\t:if (\$\"sent\" = \$pingcount) do={\r\
    \n\t\t:set avgRtt \$\"avg-rtt\"\r\
    \n\t\t:set pout \$sent\r\
    \n\t\t:set pin \$received\r\
    \n\t}\r\
    \n}\r\
    \n:local ploss (100 - ((\$pin * 100) / \$pout))\r\
    \n\r\
    \n# Bandwidth test\r\
    \n/tool bandwidth-test \$server duration=\$duration direction=both user=\$\
    user password=\$password protocol=\$protocol random-data=yes do={\r\
    \n\t:if (\$status=\"running\") do={\r\
    \n\t\t:set rxtaA (\$\"rx-total-average\" / 1000)\r\
    \n\t\t:set rxtaB (\$rxtaA / 1000 * 1000)\r\
    \n\t\t:set rxtaC (\$rxtaA - \$rxtaB)\r\
    \n\t\t:set rxtaB (\$rxtaB / 1000)\r\
    \n\t\t:set rxta \"\$rxtaB.\$rxtaC\"\r\
    \n\t\t:set txtaA (\$\"tx-total-average\" / 1000)\r\
    \n\t\t:set txtaB (\$txtaA / 1000 * 1000)\r\
    \n\t\t:set txtaC (\$txtaA - \$txtaB)\r\
    \n\t\t:set txtaB (\$txtaB / 1000)\r\
    \n\t\t:set txta \"\$txtaB.\$txtaC\"\r\
    \n\t}\r\
    \n}\r\
    \n\r\
    \n:log info \"Network-test done, e-mail-ing results (ping avg: \$avgRtt ms\
    , pkt loss: \$ploss%, TX avg: \$txta Mbps/s, RX avg: \$rxta Mbps/s)\"\r\
    \n\r\
    \n# E-mail results\r\
    \n/tool e-mail send to=\$email server=\$smtp subject=\"Network-test done :\
    \_\$sysname\" body=\"\$sysname \\n  \$datetime \\n \\n Result : \\n Ping a\
    verage: \$avgRtt ms \\n Packet loss: \$ploss % \\n TX total \$duration ave\
    rage: \$txta Mbps/s \\n RX total \$duration average: \$rxta Mbps/s\""
/system scheduler
add interval=$NwTestRuninterval name=NetTest_hourly on-event="/system script run networktest" policy=read,test start-time=startup
/system script environment
remove NwTestServer
remove NwTestUser
remove NwTestPass
remove NwTestEmail
remove NwTestSmtp
remove NwTestRuninterval