FROM scratch

ADD rootfs-docker.tgz /

ENV PATH  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/module-nmc/bin-lnx/
ENV NEURO /opt/module-nmc
ENV HOME  /var/lib/jenkins

RUN echo "deb http://shadowblade/repo/debian jessie main" >> /etc/apt/sources.list
RUN apt-get update

ENTRYPOINT ["/bin/bash", "--login"]
