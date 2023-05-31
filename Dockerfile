FROM debian:bullseye-backports

MAINTAINER CTassisF@users.noreply.github.com

SHELL ["/bin/bash", "-c"]

RUN apt-get -y update &&\
 apt-get -t bullseye-backports -y install build-essential cmake git golang gnupg libpcre2-dev libunwind-dev mercurial ninja-build zlib1g-dev

WORKDIR /build

RUN git clone https://boringssl.googlesource.com/boringssl

WORKDIR boringssl
WORKDIR build

RUN cmake -DCMAKE_BUILD_TYPE=Release -GNinja .. &&\
 ninja

WORKDIR /build
WORKDIR boringssl
WORKDIR .openssl

RUN ln -s ../include

WORKDIR lib

RUN ln -s ../../build/crypto/libcrypto.a &&\
 ln -s ../../build/decrepit/libdecrepit.a &&\
 ln -s ../../build/ssl/libssl.a

WORKDIR /build

RUN hg clone -b quic https://hg.nginx.org/nginx-quic

WORKDIR nginx-quic

RUN dpkg-buildflags --export=sh > source.sh &&\
 source source.sh &&\
 rm source.sh &&\
 ./auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt="$CFLAGS" --with-ld-opt="$LDFLAGS" --with-openssl=../boringssl &&\
 touch ../boringssl/.openssl/include/openssl/ssl.h &&\
 make
