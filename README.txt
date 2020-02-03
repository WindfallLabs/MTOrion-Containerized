# NOTE: this should be formatted in .md

Files:
Running update.sh RUNs the MS SQL Server container, updates it, downloads requirements,
copies container.py, debug.sh, and counties.txt over, and executes container.py.

container.py downloads the DOR databases for any county listed in the counties.txt file (maintained by the client), extracts the zips, renames the extracted Output.mdf to <county name>.mdf, and ATTACHes the .mdf
files to the server.

The client can then connect this containerized MS SQL Server and attached databases to ArcGIS or QGIS.

debug.sh installs optional requirements based around testing in IPython.

Use:
$ sudo ./update.sh
# Open bash on the container
$ sudo docker exec -it sqlserver /bin/bash/
# Run SQLCMD
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA 
# -- Enter password: my$uperStr0ngPwd5!

Once in:
1> USE <your database>;
2> GO
1> <More SQL, etc>
...

Or, connect to it with 
>>> ms = db2.MSSQLDB("SA", "my$uperStr0ngPwd5!", "localhost", "Missoula") 
>>> ms.sql("USE Missoula")
etc.


Close:
$ sudo docker stop sqlserver
$ sudo docker rm sqlserver

Now it's cleared and update.sh is OK to run again
