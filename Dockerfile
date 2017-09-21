FROM jetbrains/teamcity-agent
LABEL maintainer "José Maia <josecbmaia@outlook.pt>"

#Install .NET and Mono
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
	mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \ 
	sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
    apt-get update && \
	apt-get install dotnet-sdk-2.0.0 -y

RUN sh -c 'echo "deb http://download.mono-project.com/repo/ubuntu xenial main" > /etc/apt/sources.list.d/mono-official.list' && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
	apt-get update && \
	apt-get install mono-complete -y 

#to be tested. may or may not be necessary due to https://bugzilla.xamarin.com/show_bug.cgi?id=57019
RUN export MONO_TLS_PROVIDER=legacy 

# Install Node
RUN sh -c 'echo "deb https://deb.nodesource.com/node_6.x xenial main" > /etc/apt/sources.list.d/nodesource.list' && \
	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
	apt-get update && \
	apt-get install nodejs -y 

RUN mkdir -p /root/.npm/node-sass/4.5.3/ && \
curl -L https://github.com/sass/node-sass/releases/download/v4.5.3/linux-x64-48_binding.node > /root/.npm/node-sass/4.5.3/linux-x64-48_binding.node

RUN (crontab -u root -l; echo "@reboot ./run-agent.sh" ) | crontab -u root -

#Setup volumes for possible mapping to host
VOLUME /opt/buildagent/logs
VOLUME /opt/buildagent/plugins

# Setup timezones for HTTPS
ENV TZ 'Europe/London'
RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \
apt-get clean

# Add docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.16.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose && \
apt-get update && \
apt-get install docker-compose -y

# Add Docker SDK for when building a solution that has the Docker tools project.
RUN curl -H 'Cache-Control: no-cache' -o /tmp/Microsoft.Docker.Sdk.tar.gz https://distaspnet.blob.core.windows.net/sdk/Microsoft.Docker.Sdk.tar.gz \
    && cd /usr/share/dotnet/sdk/${DOTNET_SDK_VERSION}/Sdks \
    && tar xf /tmp/Microsoft.Docker.Sdk.tar.gz \
    && rm /tmp/Microsoft.Docker.Sdk.tar.gz

ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"