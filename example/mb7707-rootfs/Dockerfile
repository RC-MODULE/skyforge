FROM scratch

ADD rootfs-docker.tar.gz /
ADD module-nmc-20140702.tar.gz /opt

RUN echo "export PATH=$PATH:/opt/module-nmc/bin-lnx/" > /root/.bashrc
RUN echo "export NEURO=/opt/module-nmc" >> /root/.bashrc

ENV PATH  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/module-nmc/bin-lnx/
ENV NEURO /opt/module-nmc
ENV HOME  /var/lib/jenkins

RUN apt-get update
RUN apt-get install fakeroot

RUN chmod 777 /etc/passwd
RUN chmod 777 /etc/group
RUN chmod 777 /root
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers    
#RUN ln -sf /var/lib/jenkins/.gnupg /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login"]
