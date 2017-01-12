FROM openjdk:8-jre

# Install mongo tools for evolutions
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
  && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
  && apt-get update \
  && apt-get install -y mongodb-org-shell mongodb-org-tools \
  && rm -rf /var/lib/apt/lists/*

ENV INSTALL_DIR /srv/time-tracker

RUN mkdir -p "$INSTALL_DIR" \
  && groupadd -r app-user \
  && useradd -r -g app-user app-user \
  && cd /srv/time-tracker \
  && mkdir disk \
  && chown -R app-user .

WORKDIR $INSTALL_DIR

COPY target/universal/stage .

USER app-user

ENTRYPOINT ["bin/time-tracker"]
CMD ["-Dconfig.file=conf/application.conf", "-Dhttp.port=9000", "-Dlogger.file=conf/application-logger-prod.xml"]
