FROM public.ecr.aws/docker/library/tomcat:8.5-jdk11-openjdk

MAINTAINER Bravo-ADU

ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION

ARG USERNAME=adu
ARG USER_UID=294612
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# TBA
# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
# && apt-get update \
# && apt-get install -y sudo \
# && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
# && chmod 0440 /etc/sudoers.d/$USERNAME

LABEL \
    org.opencontainers.image.title=eric-availability-endpoint-watcher \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION

ADD watcher/target/watcher.war /usr/local/tomcat/webapps/

RUN apt-get -y update
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN apt-get -y install vim
RUN apt-get -y install less
RUN apt-get -y install procps
RUN apt-get -y install postgresql-client
RUN apt-get -y install ldap-utils
RUN pip3 install kubernetes
RUN pip3 install jproperties

RUN mkdir -p /usr/local/adu
COPY watcher/src/main/resources/aduWatcher.py /usr/local/adu/
COPY watcher/src/main/resources/neo4jWatcher.py /usr/local/adu/
COPY watcher/src/main/resources/upgradeStatus.py /usr/local/adu/
COPY watcher/src/main/resources/getImagePullTime.py /usr/local/adu/
COPY watcher/src/main/resources/aduLoggerConfig.py /usr/local/adu/
COPY watcher/src/main/resources/watcherInit.py /usr/local/adu/
COPY watcher/src/main/resources/init.sh /usr/local/adu/
COPY watcher/src/main/resources/adu.properties /usr/local/adu/
COPY watcher/src/main/resources/image.properties /usr/local/adu/
COPY watcher/src/main/resources/getNeo4jPodIp.sh /usr/local/adu/
COPY watcher/src/main/resources/ldapWatcher.py /usr/local/adu/
COPY watcher/src/main/resources/getEndpointJson.py /usr/local/adu/
COPY watcher/src/main/resources/readCatalinaFile.sh /usr/local/adu/
COPY watcher/src/main/resources/fanInjectFile.sh /usr/local/adu/
COPY watcher/src/main/resources/smrsBackupFileCleanup.sh /usr/local/adu/
COPY watcher/src/main/resources/getFtsDowntimeWindows.sh /usr/local/adu/
COPY watcher/src/main/resources/postgresWatcher.py /usr/local/adu/
COPY watcher/src/main/resources/executeCommand.sh /usr/local/adu/

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod +x get_helm.sh
RUN ./get_helm.sh
RUN chmod +x /usr/local/adu/aduWatcher.py
RUN chmod +x /usr/local/adu/neo4jWatcher.py
RUN chmod +x /usr/local/adu/upgradeStatus.py
RUN chmod +x /usr/local/adu/aduLoggerConfig.py
RUN chmod +x /usr/local/adu/watcherInit.py
RUN chmod +x /usr/local/adu/init.sh
RUN chmod +x /usr/local/adu/getNeo4jPodIp.sh
RUN chmod +x /usr/local/adu/getImagePullTime.py
RUN chmod +x /usr/local/adu/ldapWatcher.py
RUN chmod +x /usr/local/adu/getEndpointJson.py
RUN chmod +x /usr/local/adu/readCatalinaFile.sh
RUN chmod +x /usr/local/adu/fanInjectFile.sh
RUN chmod +x /usr/local/adu/smrsBackupFileCleanup.sh
RUN chmod +x /usr/local/adu/getFtsDowntimeWindows.sh
RUN chmod +x /usr/local/adu/postgresWatcher.py
RUN chmod +x /usr/local/adu/executeCommand.sh

RUN chown $USER_UID:$USER_GID /var
RUN chown $USER_UID:$USER_GID -R /usr/local/adu
RUN chown $USER_UID:$USER_GID -R /usr/local/tomcat

USER $USERNAME

CMD ["/usr/local/adu/init.sh"]
