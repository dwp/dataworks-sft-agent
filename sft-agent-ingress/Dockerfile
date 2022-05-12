FROM python:3.8.10-alpine3.13 AS builder
## Replace with your s3 bucket name

# Tagging to master to fix cache issue in 1.86 as 1.87 not buildable.
ENV S3FS_VERSION v1.88

RUN apk update && apk upgrade && apk add git automake autoconf alpine-sdk fuse libxml2-dev fuse-dev curl-dev
RUN git config --global http.sslVerify false
RUN git clone --depth 1 --branch ${S3FS_VERSION} https://github.com/s3fs-fuse/s3fs-fuse.git

RUN cd s3fs-fuse && \
    ./autogen.sh && \
    ./configure --prefix=/opt/s3fs-fuse && \
    make && \
    make install

FROM python:3.8.10-alpine3.13

ENV USER=root
ENV acm_cert_helper_version="0.37.0"
ARG jmx_exporter_version="0.15.0"

VOLUME [ "/mnt/tmp" ]

COPY --from=builder /opt/s3fs-fuse /opt/s3fs-fuse

RUN apk update && apk upgrade && apk add fuse libxml2 libstdc++ curl rsync


RUN echo "===> Installing Dependencies ..." \
    && echo "===> Updating base packages ..." \
    && apk update \
    && apk upgrade \
    && echo "==Update done==" \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache util-linux \
    && apk add --no-cache curl \
    && apk add --no-cache openjdk8-jre \
    && apk add --no-cache aws-cli \
    && echo "===> Installing acm_pca_cert_generator ..." \
    && apk add --no-cache g++ gcc musl-dev libffi-dev openssl-dev gcc cargo  \
    && pip3 install https://github.com/dwp/acm-pca-cert-generator/releases/download/${acm_cert_helper_version}/acm_cert_helper-${acm_cert_helper_version}.tar.gz \
    && echo "==Dependencies done=="

RUN mkdir app
RUN mkdir data-ingress
RUN mkdir -p /opt/data-ingress

WORKDIR /app

COPY files/sft-agent-jre8-2.3.1a4ce31c2971dc408da388c33f4228e73ecbaa2548b5a9cbf6528d6657210d71c.jar sft-agent.jar
COPY sft-agent-ingress/entrypoint.sh ./

# Jmx Exporter
RUN mkdir -p /opt/jmx_exporter
COPY files/jmx_exporter_config.yml /opt/jmx_exporter/
RUN curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${jmx_exporter_version}/jmx_prometheus_javaagent-${jmx_exporter_version}.jar -o /opt/jmx_exporter/jmx_exporter.jar

# Set user to run the process as in the docker contianer
ENV USER_NAME=root
ENV GROUP_NAME=root

RUN chown -R $USER_NAME.$GROUP_NAME /etc/ssl/
RUN chown -R $USER_NAME.$GROUP_NAME /usr/local/share/ca-certificates/
RUN chown -R $USER_NAME.$GROUP_NAME /app
RUN chown -R $USER_NAME.$GROUP_NAME /var
RUN chown -R $USER_NAME.$GROUP_NAME /opt/data-ingress
RUN chmod g+rwX /data-ingress
RUN chmod a+rw /var/log
RUN chmod 0755 entrypoint.sh
USER $USER_NAME

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
