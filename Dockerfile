FROM centos:7
MAINTAINER Tobias Florek tob@butter.sh

EXPOSE 20/tcp 20/udp 21/tcp 21/udp 115/tcp 115/udp

RUN rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
 && yum --setopt=tsflags=nodocs -y install vsftpd \
 && yum clean all \
 && mkdir -p /home/vftp \
 && chown ftp:ftp /home/vftp

ADD entrypoint.sh /usr/libexec/container/
ADD pam.d/ /etc/pam.d/

VOLUME ["/home/vftp"]
CMD ["/usr/libexec/container/entrypoint.sh"]
