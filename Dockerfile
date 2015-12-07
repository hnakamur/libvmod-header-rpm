FROM centos:7
MAINTAINER Hiroaki Nakamura <hnakamur@gmail.com>

ENV LIBVMOD_HEADER_GIT_BRANCH 4.1

RUN yum -y install epel-release \
 && yum -y install rpmdevtools rpm-build patch python-pip \
 && pip install copr-cli \
 && rpmdev-setuptree \
 && cd /root/rpmbuild/SOURCES \
 && curl -sLO https://github.com/lkarsten/libvmod-header/archive/${LIBVMOD_HEADER_GIT_BRANCH}.tar.gz#/libvmod-header-${LIBVMOD_HEADER_GIT_BRANCH}.tar.gz

ADD libvmod-header.spec /root/rpmbuild/SPECS/

RUN cd /root/rpmbuild/SPECS \
 && rpmbuild -bs libvmod-header.spec

ADD copr-build.sh /root/
ENTRYPOINT ["/bin/bash", "/root/copr-build.sh"]
