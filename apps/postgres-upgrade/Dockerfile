FROM postgres:17.4

RUN apt update

RUN apt install -y rsync
RUN apt install -y postgresql-13
RUN apt install -y postgresql-14
RUN apt install -y postgresql-15
RUN apt install -y postgresql-16

RUN apt autoremove -y
RUN apt autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /tmp
