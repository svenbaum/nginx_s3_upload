

FROM ubuntu

MAINTAINER Sven Baum <svenbaum@gmail.com>

# NOTE: not required for uploads:  
# nginx-upload-modul
# ngx_cache_purge

ENV NGINX_VERSION 1.6.2
ENV NGINX_DEVEL_KIT_VERSION 0.2.19
ENV SET_MISC_NGINX_VERSION 0.28
ENV NGINX_DAV_EXT_VERSION 0.0.3
ENV NGINX_UPLOAD_VERSION 2.2
ENV NGINX_CACHE_PURGE_VERSION 2.3
ENV LUA_NGINX_MODULE_VERSION 0.9.15


# Install prerequisites for Nginx compile
RUN apt-get update && \
    apt-get install -y wget tar gcc libpcre3 libpcre3-dev zlib1g-dev make libssl-dev libnet-ifconfig-wrapper-perl ssh vim tree git \ 
    lua-expat-dev expat lua-expat libexpat-dev mlocate unzip libxml2 libxslt-dev libluajit-5.1-dev libterm-readline-perl-perl curl  

# INstall prerequisites
WORKDIR /tmp

# Download Nginx
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O nginx-${NGINX_VERSION}.tar.gz && \
    mkdir nginx && \
    tar xf nginx-${NGINX_VERSION}.tar.gz -C nginx --strip-components=1

# Download Nginx modules
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEVEL_KIT_VERSION.tar.gz -O ngx_devel_kit.tar.gz && \
  mkdir ngx_devel_kit && \
  tar xf ngx_devel_kit.tar.gz -C ngx_devel_kit --strip-components=1

RUN wget https://github.com/openresty/set-misc-nginx-module/archive/v$SET_MISC_NGINX_VERSION.tar.gz -O set-misc-nginx-module.tar.gz && \
    mkdir set-misc-nginx-module && \
    tar xf set-misc-nginx-module.tar.gz -C set-misc-nginx-module --strip-components=1

RUN wget https://github.com/arut/nginx-dav-ext-module/archive/v${NGINX_DAV_EXT_VERSION}.tar.gz -O nginx-dav-ext-module.tar.gz && \
    mkdir nginx-dav-ext-module && \
    tar xf nginx-dav-ext-module.tar.gz -C nginx-dav-ext-module --strip-components=1

RUN wget https://github.com/vkholodkov/nginx-upload-module/archive/$NGINX_UPLOAD_VERSION.tar.gz -O nginx-upload-module.tar.gz && \
    mkdir nginx-upload-module && \
    tar xf nginx-upload-module.tar.gz -C nginx-upload-module --strip-components=1

RUN wget http://labs.frickle.com/files/ngx_cache_purge-${NGINX_CACHE_PURGE_VERSION}.tar.gz -O ngx_cache_purge.tar.gz  && \
  mkdir ngx_cache_purge && \
  tar xf ngx_cache_purge.tar.gz -C ngx_cache_purge --strip-components=1

# => OK 
RUN wget https://github.com/openresty/lua-nginx-module/archive/v$LUA_NGINX_MODULE_VERSION.tar.gz -O lua-nginx-module.tar.gz && \
    mkdir lua-nginx-module && \
    tar xf lua-nginx-module.tar.gz -C lua-nginx-module --strip-components=1


WORKDIR nginx

RUN       ./configure --sbin-path=/usr/local/sbin \
                    --conf-path=/etc/nginx/nginx.conf \
                    --pid-path=/var/run/nginx.pid \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \
                    --with-http_ssl_module \
                    --with-http_gzip_static_module \
                    --with-http_dav_module \
                    --add-module=/tmp/ngx_devel_kit \ 
                    --add-module=/tmp/set-misc-nginx-module \
                    --add-module=/tmp/nginx-dav-ext-module \ 
                    --add-module=/tmp/nginx-upload-module \  
                    --add-module=/tmp/ngx_cache_purge \
                    --add-module=/tmp/lua-nginx-module && \


  make -j2 && \
  make install 

# Apply Nginx config
ADD config/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/cache/NGINX_pagespeed
RUN mkdir -p /usr/local/nginx/upload/data
RUN mkdir -p /usr/local/nginx/upload/client_tmp

# Expose ports
EXPOSE 80

# Set default command
CMD ["nginx", "-g", "daemon off;"]



