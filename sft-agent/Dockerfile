FROM python:3.8.10-alpine3.13

ENV acm_cert_helper_version="0.37.0"
ARG jmx_exporter_version="0.15.0"
RUN echo "===> Installing Dependencies ..." \
    && echo "===> Updating base packages ..." \
    && apk update \
    && apk upgrade \
    && echo "==Update done==" \
    && apk add --no-cache util-linux \
    && apk add --no-cache curl \
    && apk add --no-cache openjdk8-jre \
    && apk add --no-cache aws-cli \
    && echo "===> Installing acm_pca_cert_generator ..." \
    && apk add --no-cache g++ gcc musl-dev libffi-dev openssl-dev gcc cargo  \
    && pip3 install https://github.com/dwp/acm-pca-cert-generator/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz \
    && echo "==Dependencies done=="

RUN mkdir app
RUN mkdir data-egress
RUN mkdir -p /opt/data-egress

WORKDIR /app

# Data volume
VOLUME [ "/data-egress" ]

COPY ../sft-agent-jre8-2.3.1a4ce31c2971dc408da388c33f4228e73ecbaa2548b5a9cbf6528d6657210d71c.jar sft-agent.jar
COPY ../entrypoint.sh ./

# Jmx Exporter
RUN mkdir -p /opt/jmx_exporter
COPY ../jmx_exporter_config.yml /opt/jmx_exporter/
RUN curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${jmx_exporter_version}/jmx_prometheus_javaagent-${jmx_exporter_version}.jar -o /opt/jmx_exporter/jmx_exporter.jar

# Set user to run the process as in the docker contianer
ENV USER_NAME=root
ENV GROUP_NAME=root

RUN chown -R $USER_NAME.$GROUP_NAME /etc/ssl/
RUN chown -R $USER_NAME.$GROUP_NAME /usr/local/share/ca-certificates/
RUN chown -R $USER_NAME.$GROUP_NAME /app
RUN chown -R $USER_NAME.$GROUP_NAME /var
RUN chown -R $USER_NAME.$GROUP_NAME /opt/data-egress
RUN chmod g+rwX /data-egress
RUN chmod a+rw /var/log
RUN chmod 0755 entrypoint.sh
USER $USER_NAME

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
