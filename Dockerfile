FROM debian
RUN apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean -y
RUN apt install ssh curl wget zip htop screen npm tree cron supervisor -y
RUN npm install -g wstunnel

RUN cd /root \
  && wget https://github.com/cloudflare/cloudflared/releases/download/2023.3.0/cloudflared-linux-amd64.deb \
  && dpkg -i cloudflared-linux-amd64.deb \
  && rm cloudflared-linux-amd64.deb \
  && wget https://github.com/txthinking/brook/releases/download/v20230122/brook_linux_amd64 \
  && chmod +x brook_linux_amd64 && mv brook_linux_amd64 /usr/local/bin/brook

RUN mkdir /run/sshd
RUN echo 'wstunnel -s 0.0.0.0:80 &' >>/run.sh
RUN echo '/usr/sbin/sshd -D' >>/run.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
RUN echo root:railway|chpasswd
RUN chmod 755 /run.sh
EXPOSE 80 443 60000 65535
CMD /run.sh
