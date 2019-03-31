
# Downgrade docker
#apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

# Run container
docker run --name 'sqlserver' -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=my$uperStr0ngPwd5!' -e 'MSSQL_PID=Express' -p 1433:1433 -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu

# Update
docker exec -it sqlserver sh -c "apt-get update"
# Install requirements
#


# TODO: copy entire folder (or get from git)
# Copy county list to container
docker cp ./counties.txt sqlserver:/home/counties.txt

# Copy debug instructions (ipython)
docker cp ./debug.sh sqlserver:/home/debug.sh

# Get container.py script
#docker exec -it sqlserver sh -c "cd home && wget https://gist.githubusercontent.com/WindfallLabs/d1904bbb0e662d2ad761054d7929d929/raw/63f8b2fb23dd52d1bf6188f3a6c3dc6be4b2d32a/container.py -O container.py"
docker cp ./container.py sqlserver:/home/container.py

# Execute container.py
docker exec -it sqlserver sh -c "cd home && python container.py"