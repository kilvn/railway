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
  && wget https://github.com/cloudflare/cloudflared/releases/download/2023.3.0/cloudflared-linux-amd64.deb \
  && dpkg -i cloudflared-linux-amd64.deb \
  && rm cloudflared-linux-amd64.deb \
  && wget https://github.com/txthinking/brook/releases/download/v20230122/brook_linux_amd64 \
  && chmod +x brook_linux_amd64 && mv brook_linux_amd64 /usr/local/bin/brook \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list \
  && apt update && apt install -y tailscale

RUN cd /etc/supervisor/conf.d \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/conf/brook.conf \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/conf/cloudflared.conf \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/conf/tailscale.conf \
  && systemctl enable supervisor && supervisor -c /etc/supervisor/supervisor.conf \
  && cd /root/.cloudflare \
  && wget https://raw.githubusercontent.com/kilvn/railway/master/conf/config.yml \
  && supervisorctl update

EXPOSE 80 443 60000 65535

CMD /run.sh
