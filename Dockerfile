FROM openjdk:8

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN rm -rf ./aws/

COPY sft-agent-jre8-2.3.1a4ce31c2971dc408da388c33f4228e73ecbaa2548b5a9cbf6528d6657210d71c.jar /app/sft-agent.jar
COPY entrypoint.sh /app/

WORKDIR /app

CMD ["/bin/bash", "entrypoint.sh"]
