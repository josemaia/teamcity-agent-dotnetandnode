FROM jetbrains/teamcity-agent

RUN sh -c 'echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
    apt-get update

RUN apt-get install dotnet-dev-1.0.4 -y

RUN apt-get install mono-devel mono-xbuild libmono-addins-* -y 

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/logs
VOLUME /data/teamcity_agent/conf
VOLUME /opt/buildagent/plugins

ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"

