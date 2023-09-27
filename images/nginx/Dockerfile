#Base Image Dockerfile - https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
#Base Image Repo - https://hub.docker.com/_/nginx
ARG BASE_IMAGE_TAG='1.23.2-alpine'
FROM nginx:$BASE_IMAGE_TAG

ENV LANG=LANG=C.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=C.UTF-8 \
  NGINX_LISTEN_IP='0.0.0.0' \
  NGINX_HTTP_PORT='8080' \
  NGINX_HTTPS_PORT='8443' \
  NGINX_SSL_CERT='/etc/ssl/nginx.crt' \
  NGINX_SSL_KEY='/etc/ssl/nginx.key' \
  NGINX_CACHE_DIR='/var/cache/nginx' \
#NOTE: user for running worker processes
  NGINX_USER='nginx' \
#NOTE: Folder that contains nginx config templates
  NGINX_ENVSUBST_TEMPLATE_DIR='/etc/nginx/templates' \
#NOTE: Suffix that determines nginx config templates and that will be deleted after replacement
  NGINX_ENVSUBST_TEMPLATE_SUFFIX='.conf' \
#NOTE: Folder in which the result of executing envsubst is output
  NGINX_ENVSUBST_OUTPUT_DIR='/etc/nginx/conf.d' \
#NOTE: DH parameters for DHE ciphers (provides Forward secrecy)
  NGINX_SSL_DHPARAM='/etc/ssl/dhparams.pem' \
#NOTE: If not empty then entrypoint script autotune the number of worker processes (https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/30-tune-worker-processes.sh)
  NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=''\
#NOTE: Consul HTTP check (if empty, then don't register in the Consul)
  NGINX_CONSUL_CHECK=""

EXPOSE ${NGINX_HTTP_PORT} ${NGINX_HTTPS_PORT}

# nginx need to be running as root
USER root

### Copy Dockerfile, entrypoint script into container, add healthcheck and some support scripts###
COPY Dockerfile \
    healthcheck.sh \
    /
COPY ./docker-entrypoint-custom.d/* /docker-entrypoint.d/
# The start-period is just a wild guess how long it takes PuppetDB to come up in the worst case. The other timing parameters are set so that it takes at most a minute to realize that PuppetDB has failed.
# NOTE: Probe failure during --start-period will not be counted towards the maximum number of retries
# NOTE: k8s uses livenessProbe, startupProbe, readinessProbe and ignores HEALTHCHECK
HEALTHCHECK --start-period=5m --interval=10s --timeout=10s --retries=6 CMD ["/healthcheck.sh"]

### Install main dependecies
RUN apk update && \
  apk add --no-cache curl openssl ca-certificates bash && \
  chmod +x /docker-entrypoint.d/*.sh /healthcheck.sh && \
  mkdir -p /etc/ssl/ && mkdir -p ${NGINX_CACHE_DIR} && \
  rm -rf /etc/nginx/conf.d/*

### Configuration files ###
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/dhparams.pem /etc/ssl/dhparams.pem
COPY ./config/conf.d/ /etc/nginx/templates