FROM debian

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean -y
RUN apt install ssh curl wget vim nano lsof zip htop screen npm tree cron supervisor -y
RUN npm install -g wstunnel
RUN mkdir /run/sshd
RUN echo 'wstunnel -s 0.0.0.0:80 &' >>/run.sh
RUN echo '/usr/sbin/sshd -D' >>/run.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
RUN echo root:railway|chpasswd
RUN chmod 755 /run.sh

RUN cd /root \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/tailscale_start.sh && chmod +x tailscale_start.sh \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list \
  && apt update && apt install -y tailscale

RUN cd /etc/supervisor/conf.d \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/conf/tailscale.conf \
  && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf \
  && /usr/bin/supervisorctl update

EXPOSE 80

CMD /run.sh
