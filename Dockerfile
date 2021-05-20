FROM openjdk:8

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && rm awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws/

# Data volume
VOLUME [ "/data-egress" ]

# Working from data dir
WORKDIR /data-egress

COPY sft-agent-jre8-2.3.1a4ce31c2971dc408da388c33f4228e73ecbaa2548b5a9cbf6528d6657210d71c.jar sft-agent.jar
COPY entrypoint.sh agent-config.yml agent-application-config.yml ./

RUN chmod g+rwX /data-egress
RUN chmod 0755 entrypoint.sh

EXPOSE 8080



ENTRYPOINT ["./entrypoint.sh"]
