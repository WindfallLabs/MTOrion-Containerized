# NOTE: this should be formatted in .md

Files:
update.sh is run by the client. It RUNs the MS SQL Server container, updates it, downloads requirements,
copies container.py, debug.sh, and counties.txt over, and executes container.py.

container.py downloads the DOR databases for any county listed in the counties.txt file (maintained by the client), extracts the zips, renames the extracted Output.mdf to <county name>.mdf, and ATTACHes the .mdf
files to the server.

The client can then connect this containerized MS SQL Server and attached databases to ArcGIS or QGIS.

debug.sh installs optional requirements based around testing in IPython.