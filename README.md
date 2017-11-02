# teamcity-agent-dotnetandnode

Docker image for a TeamCity agent with pre-installed .NET Core and NodeJS

See https://hub.docker.com/r/josemaia/teamcity-agent-dotnetandnode/

# How to Use
## Create a new teamcity dotnet/node build agent:

(On the docker host)

sudo docker run -d -it -e \
SERVER_URL="https://teamcity.example.com" \
-v /opt/data/Docker/buildagent001/conf/:/data/teamcity_agent/conf  \
-v /opt/data/Docker/buildagent001/plugins/:/opt/buildagent/plugins/  \
-v /opt/data/Docker/buildagent001/work/:/opt/buildagent/work/  \
--restart=always --privileged -e DOCKER_IN_DOCKER="start"  \
-e AGENT_NAME="buildagent001" --name buildagent001  \
josemaia/teamcity-agent-dotnetandnode

Replace buildagent001 with the desired name, and the server URL with your own. 
Make sure the /opt/data/Docker/buildagent001/conf/ and /plugins/ folders already exist!

The work folder mounting is optional, but the conf and plugins mounts are heavily recommended.

The flags --privileged -e DOCKER_IN_DOCKER="start" are only relevant for building docker images inside the container.

## If using to build solutions that have docker:

The container may not always start its inner Docker. In this case, login to the container, and do:
systemctl enable docker

service docker start (if it isn't up)
