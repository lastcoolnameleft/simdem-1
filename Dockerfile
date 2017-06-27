FROM consol/ubuntu-xfce-vnc

### VNC config
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1024x768
ENV VNC_PW vncpassword

USER 0

RUN apt-get update

RUN apt-get install sudo -y
RUN apt-get install whois -y
RUN sudo useradd default -u 1984 -p `mkpasswd vncpassword`
RUN sudo usermod -aG sudo default

# Not really needed, but used in the SimDem demo script
RUN apt-get install tree -y

# Azure CLI
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get install apt-transport-https -y
RUN apt-get update
RUN apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
RUN apt-get install azure-cli -y --allow-unauthenticated
RUN mkdir -p .azure

# Python
RUN apt-get install python3-pip -y

USER 1984

# Desktop
COPY ./novnc/ /headless/
RUN rm .config/bg_sakuli.png

# SimDem
COPY ./requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
USER 0
COPY simdem.py /usr/local/bin/simdem.py
RUN chmod +x /usr/local/bin/simdem.py
RUN ln -s /usr/local/bin/simdem.py /usr/local/bin/simdem
USER 1984

COPY demo_scripts demo_scripts
