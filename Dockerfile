FROM debian:wheezy
MAINTAINER xupeng recordus@gmail.com

ENV PATH /usr/local/sbin:/usr/local/bin:/sbin:/usr/sbin:/bin:/usr/bin
ENV OCSERV_VERSION 0.8.4

RUN echo deb http://http.debian.net/debian wheezy-backports main >> /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
		curl \
		net-tools \
		iptables \
		procps \
		vim-nox \
		build-essential \
		pkg-config \
		openssl \
	&& apt-get install -t wheezy-backports -y \
		libgnutls28-dev \
		libreadline6-dev \
		gnutls-bin \
	&& mkdir -p /ocserv \
	&& mkdir -p /tmp/ocserv \
	&& cd /tmp/ocserv \
	&& curl -SL ftp://ftp.infradead.org/pub/ocserv/ocserv-${OCSERV_VERSION}.tar.xz 2>/dev/null | tar -xJ \
	&& ls /tmp/ocserv \
	&& cd /tmp/ocserv/ocserv-${OCSERV_VERSION}/ \
	&& ./configure \
	&& make \
	&& make install \
	&& rm -rf /tmp/ocserv \
	&& apt-get purge -y build-essential curl \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /dev/net && [ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200 && chmod 600 /dev/net/tun

VOLUME ["/ocserv"]
EXPOSE 443

WORKDIR /ocserv
COPY run-ocserv /usr/local/sbin/run-ocserv
COPY ocserv.conf /ocserv-template/ocserv.conf

CMD ["run-ocserv"]
