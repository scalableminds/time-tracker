FROM java:8-jre

# Install mongo tools for evolutions
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
  && echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
  && apt-get update \
  && apt-get install -y mongodb-org-shell=3.2.1 mongodb-org-tools=3.2.1

ENV PROJECT "time-tracker"
ENV INSTALL_DIR /srv/time-tracker
ENV APPLICATION_CONFIG ${INSTALL_DIR}/conf/application_${MODE:-dev}.conf
ENV PORT 12000
ENV LOGGER_XML ${INSTALL_DIR}/conf/application-logger.xml

RUN mkdir -p /srv/time-tracker
WORKDIR /srv/time-tracker

COPY target/universal/stage .

RUN groupadd -r app-user \
  && useradd -r -g app-user app-user \
  && mkdir disk \
  && chown -R app-user .

USER app-user


ENTRYPOINT ./bin/time-tracker -Dconfig.file=$APPLICATION_CONFIG -Dhttp.port=$PORT -Dmongodb.url=mongo -Dmongodb.port=27017
