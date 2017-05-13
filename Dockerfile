FROM ubuntu
MAINTAINER santhosh  santhoshkumar@powerupcloud.com

# update , install supervisord , redis & basics
RUN apt-get update && apt-get -y upgrade && apt-get install supervisor curl wget vim sudo -y && apt-get -y install redis-server logrotate  g++ libstdc++6 libstdc++-4.9-dev make

#install sensu 
RUN wget -q http://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | sudo apt-key add - && echo "deb     http://sensu.global.ssl.fastly.net/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list && sudo apt-get update && apt-get install sensu -y && apt-get install uchiwa

#install erlang & rabbitmq
RUN sudo wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb && sudo apt-get update && sudo apt-get -y install socat erlang-nox=1:19.3-1 && sudo wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server_3.6.9-1_all.deb && sudo dpkg -i rabbitmq-server_3.6.9-1_all.deb

#install SSL

RUN cd /opt && wget http://sensuapp.org/docs/0.29/files/sensu_ssl_tool.tar && tar -xvf sensu_ssl_tool.tar && cd sensu_ssl_tool && ./ssl_certs.sh generate

RUN  sudo mkdir -p /etc/rabbitmq/ssl && sudo cp /opt/sensu_ssl_tool/sensu_ca/cacert.pem /opt/sensu_ssl_tool/server/cert.pem /opt/sensu_ssl_tool/server/key.pem /etc/rabbitmq/ssl

RUN sudo mkdir -p /etc/sensu/ssl && sudo cp /opt/sensu_ssl_tool/client/cert.pem /opt/sensu_ssl_tool/client/key.pem /etc/sensu/ssl

#install postfix
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y postfix 

#copy config
COPY uchiwa.json /etc/sensu/uchiwa.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf.d /etc/sensu/conf.d
COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

#install sensu plugins
RUN cd /opt/sensu/embedded/bin && sudo sensu-install -p cpu-checks && sudo sensu-install -p disk-checks && sudo sensu-install -p memory-checks && sudo sensu-install -p process-checks && sudo sensu-install -p load-checks && sudo sensu-install -p vmstats && sudo sensu-install -p mailer && sudo cp metrics-* /etc/sensu/plugins/ && sudo cp check-* /etc/sensu/plugins/ && cp handler-mailer* /etc/sensu/handlers/ 
#relay
RUN sudo apt-get install -y git && git clone git://github.com/opinionlab/sensu-metrics-relay.git && cd sensu-metrics-relay && cp -R lib/sensu/extensions/* /etc/sensu/extensions && mkdir -p /data/log/supervisor

RUN sudo service sensu-server start && sudo service redis-server start && sudo service rabbitmq-server start && sudo service sensu-api start && sudo service sensu-client start

RUN rabbitmq-plugins enable rabbitmq_management

EXPOSE 5671 15672 3000
CMD ["/usr/bin/supervisord"]
	
