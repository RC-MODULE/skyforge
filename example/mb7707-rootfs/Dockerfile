FROM scratch

ADD rootfs-docker.tgz /

ENV PATH  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/module-nmc/bin-lnx/
ENV NEURO /opt/module-nmc
ENV HOME  /var/lib/jenkins

ENTRYPOINT ["/bin/bash", "--login"]
