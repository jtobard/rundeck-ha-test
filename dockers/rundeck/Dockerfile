FROM ubuntu:16.04

# (Temporary) Change apt repository
#RUN sed -i.bak -e "s:archive.ubuntu.com:ftp.tecnoera.com:g" /etc/apt/sources.list

## General package configuration
RUN apt-get -y update && \
    apt-get -y install \
        sudo \
        unzip \
        curl \
        xmlstarlet \
        git \
        netcat-traditional \
        software-properties-common \
        debconf-utils \
        uuid-runtime \
        ncurses-bin \
        iputils-ping \
        zip

## Install Oracle JVM
RUN \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer

## DEBUG ENV VARS AT THIS POINT
#RUN echo "**** ENV VARS START ****" && printenv > /env_at_build_time && cat /env_at_build_time && echo "**** ENV VARS END ****"

# RUNDECK

## RUNDECK setup env
ARG RUNDECK_BUNDLE=rundeckpro
ARG WEBAPP_CONTEXT=rundeckpro
ARG INSTALLER_URL

ENV USERNAME=rundeck \
    USER=rundeck \
    HOME=/home/rundeck \
    LOGNAME=$USERNAME \
    TERM=xterm-256color

# RUNDECK - create user
RUN adduser --shell /bin/bash --home $HOME --gecos "" --disabled-password $USERNAME && \
    passwd -d $USERNAME && \
    addgroup $USERNAME sudo

# Build Rerun utilities
WORKDIR $HOME
RUN git clone https://github.com/rerun/rerun $HOME/rerun && \
    git clone https://github.com/rerun-modules/rundeck-apitokens $HOME/rerun/modules/rundeck-apitokens && \
    git clone https://github.com/rerun-modules/rundeck-system $HOME/rerun/modules/rundeck-system && \
    git clone https://github.com/rerun-modules/rundeck-plugin $HOME/rerun/modules/rundeck-plugin

WORKDIR $HOME/rerun
RUN ./rerun stubbs:archive -f $HOME/rrtokens --modules rundeck-apitokens && \
    ./rerun stubbs:archive -f $HOME/rrsystem --modules rundeck-system


RUN sed -i.bak -e "s|securerandom.source=file:/dev/random|securerandom.source=file:/dev/urandom|" /usr/lib/jvm/java-8-oracle/jre/lib/security/java.security

#download installer
RUN echo "download installer: ${INSTALLER_URL}"
RUN curl -sS -f -L -o $HOME/rdpro-installer ${INSTALLER_URL}
RUN sudo chmod +x $HOME/rdpro-installer
RUN rm -rf /tmp/it_* /tmp/rdpro* /tmp/RDECK*

# RUNDECK - install
RUN chown -R $USERNAME:$USERNAME $HOME
WORKDIR $HOME
USER rundeck

RUN ./rdpro-installer install-all \
      --java-opts "-Djava.security.egd=file:/dev/./urandom" \
      --http-port 4440 \
      --https-port 4443 \
      --keystore-generate true \
      --keystore-file $HOME/etc/truststore \
      --keystore-pass rundeck \
      --keystore-dname 'CN=acme.org,OU=CA,O=ACME,L=Acme,S=Acme,C=US'

RUN ./rdpro-installer configure-clustermode \
  --enabled true \
  --rdeck-base $HOME

RUN ./rdpro-installer configure-logs-dir \
  --logs-dir $HOME/logs \
  --rdeck-base $HOME

EXPOSE 22 3000 4440 4443

# Copy files.
COPY config $HOME/config
COPY scripts $HOME/scripts
RUN sudo chmod -R a+x $HOME/scripts/*

VOLUME $HOME

# Start the instance.
CMD scripts/run.sh

