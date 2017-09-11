# teamcity-agent-dotnetandnode

Docker image for a TeamCity agent with pre-installed .NET Core and NodeJS

See https://hub.docker.com/r/josemaia/teamcity-agent-dotnetandnode/

# How to Use
## Create a new teamcity dotnet/node build agent:

(On the docker host)
sudo docker run -it -e SERVER_URL="https://teamcity.example.com" -v /opt/data/Docker/buildAgent001/conf/:/data/teamcity_agent/conf -e AGENT_NAME="buildAgent001" -v /opt/data/Docker/buildAgent001/plugins/:/opt/buildagent/plugins/ --restart=always josemaia/teamcity-agent-dotnetandnode 

(replace 001 with the desired #, and the server URL with your own. make sure the /opt/data/Docker/buildAgent001/conf/ and /plugins/ folders already exist!)

If you also need to build docker images inside the host, add the flags --privileged -e DOCKER_IN_DOCKER="start"

## Start an existing one:
sudo docker container list -a

sudo docker start {serene_meninsky}(replace with ID)

## If using to build solutions that have docker:

Until https://github.com/dotnet/cli/issues/6178 / https://github.com/dotnet/cli/pull/6180 is fixed, you will need to manually copy the docker SDK to the dotnet folder.

sudo docker exec {serene_meninsky} mkdir -p /opt/dotnet/sdk/2.0.0/Sdks/Microsoft.Docker.Sdk/

sudo docker cp /opt/dotnet/sdk/2.0.0/Sdks/Microsoft.Docker.Sdk/ {serene_meninsky}:/opt/dotnet/sdk/2.0.0/Sdks/Microsoft.Docker.Sdk/

login to the container, and do:
systemctl enable docker

service docker start (if it isn't up)