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
  && COPY ./tailscale_start.sh /root/tailscale_start.sh && chmod +x tailscale_start.sh \
  && wget https://github.com/cloudflare/cloudflared/releases/download/2023.3.0/cloudflared-linux-amd64.deb \
  && dpkg -i cloudflared-linux-amd64.deb \
  && rm cloudflared-linux-amd64.deb \
  && wget https://github.com/txthinking/brook/releases/download/v20230122/brook_linux_amd64 \
  && chmod +x brook_linux_amd64 && mv brook_linux_amd64 /usr/local/bin/brook \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
  && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list \
  && apt update && apt install -y tailscale

RUN COPY ./conf/brook.conf /etc/supervisor/conf.d/brook.conf \
  && COPY ./conf/cloudflared.conf /etc/supervisor/conf.d/cloudflared.conf \
  && COPY ./conf/tailscale.conf /etc/supervisor/conf.d/tailscale.conf \
  && systemctl enable supervisor && systemctl start supervisor \
  && COYP ./conf/config.yml /root/.cloudflare/config.yml \
  && supervisorctl update

EXPOSE 80 443 60000 65535

CMD /run.sh
