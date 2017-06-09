# Python을 이용한 Azure SQL Databases 연결 모니터링하기

[https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/check_availability](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/check_availability)의 Python 버전


```Python
import socket
from time import sleep, gmtime, strftime

port = 1433
host='<<your db server name>>.database.windows.net'
sec = 10
while True:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((host, port))
        print (str(strftime("%Y-%m-%d %H:%M:%S", gmtime())) + " '" + host + "' is listening on " + str(port) + ".")
        s.close()
    except socket.error as e:
        print (str(strftime("%Y-%m-%d %H:%M:%S", gmtime())) + " Error occured ({0}): {1}".format(e.errno, e.strerror))

    sleep(sec)
```