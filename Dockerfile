FROM jetbrains/teamcity-agent
LABEL maintainer "José Maia <josecbmaia@outlook.pt>"

RUN sh -c 'echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
    apt-get update && \
	apt-get install dotnet-dev-1.0.4 -y

RUN sh -c 'echo "deb http://download.mono-project.com/repo/ubuntu xenial main" > /etc/apt/sources.list.d/mono-official.list' && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
	apt-get update && \
	apt-get install mono-complete -y 

#to be tested. may or may not be necessary due to https://bugzilla.xamarin.com/show_bug.cgi?id=57019
RUN export MONO_TLS_PROVIDER=legacy 

RUN sh -c 'echo "deb https://deb.nodesource.com/node_6.x xenial main" > /etc/apt/sources.list.d/nodesource.list' && \
	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
	apt-get update && \
	apt-get install nodejs -y 

RUN (crontab -u root -l; echo "@reboot ./run-agent.sh" ) | crontab -u root -

VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/logs
VOLUME /data/teamcity_agent/conf
VOLUME /opt/buildagent/plugins

ENV TZ 'Europe/London'
RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \
apt-get clean

RUN curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose


ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"

