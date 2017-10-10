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

#force Mono and dotnet CLI to both use the same NuGet configurations due to https://github.com/NuGet/Home/issues/4413
ln -s /root/.nuget/NuGet/NuGet.Config /root/.config/NuGet/NuGet.Config

# Install Node
RUN sh -c 'echo "deb https://deb.nodesource.com/node_6.x xenial main" > /etc/apt/sources.list.d/nodesource.list' && \
	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
	apt-get update && \
	apt-get install nodejs -y 

RUN mkdir -p /root/.npm/node-sass/4.5.3/ && \
curl -L https://github.com/sass/node-sass/releases/download/v4.5.3/linux-x64-48_binding.node > /root/.npm/node-sass/4.5.3/linux-x64-48_binding.node

RUN (crontab -u root -l; echo "@reboot ./run-agent.sh" ) | crontab -u root -
RUN (crontab -u root -l; echo "@reboot ./run-docker.sh" ) | crontab -u root -

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

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
    && cd /usr/share/dotnet/sdk/2.0.0/Sdks \
    && tar xf /tmp/Microsoft.Docker.Sdk.tar.gz \
    && rm /tmp/Microsoft.Docker.Sdk.tar.gz

ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"