FROM ubuntu:18.04 as base

# Define Prometheus home and its version
ARG PROMETHEUS_HOME=/opt/prometheus
ARG PROMETHEUS_VERSION=2.41.0

# Define TAR & folder names, as well as download URL for easier use
ARG PROMETHEUS_TAR_MAYOR=prometheus-${PROMETHEUS_VERSION}.linux-amd64
ARG PROMETHEUS_TAR_FULLNAME=${PROMETHEUS_TAR_MAYOR}.tar.gz
ARG PROMETHEUS_URL=https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR_FULLNAME}

ENV  LISTEN_PORT_HTTP='9090' \
  PROM_USER='prometheus' \
  LISTEN_IP='0.0.0.0' \
#NOTE: Consul HTTP check (if empty, then don't register in the Consul)
  PROXY_CONSUL_CHECK=''

EXPOSE ${ISTEN_PORT_HTTP} ${ISTEN_PORT_HTTP}

USER root

RUN apt update -y && \
    apt install -y curl wget && \
    apt-get clean && \
    wget ${PROMETHEUS_URL}

# Untar the file and rename it to "prometheus"
RUN tar xvfz ${PROMETHEUS_TAR_FULLNAME} -C /opt && \
    mv /opt/${PROMETHEUS_TAR_MAYOR} /opt/prometheus && \
    rm -rf /opt/prometheus/prometheus.yml && \
    groupadd -r ${PROM_USER} && \
    useradd -g ${PROM_USER} -s /bin/bash -c "Prometheus user" ${PROM_USER} && \
    chown -R ${PROM_USER}:${PROM_USER} /opt && mkdir -p /prometheus && chown -R ${PROM_USER}:${PROM_USER} /prometheus


### Copy Dockerfile, entrypoint script into container, add healthcheck and some support scripts###
COPY --chown=${PROM_USER}:${PROM_USER} \
    Dockerfile \
    healthcheck.sh \
    docker-entrypoint.sh \
    /
COPY --chown=${PROM_USER}:${PROM_USER} ./docker-entrypoint.d/* /docker-entrypoint.d/
# The start-period is just a wild guess how long it takes PuppetDB to come up in the worst case. The other timing parameters are set so that it takes at most a minute to realize that PuppetDB has failed.
# NOTE: Probe failure during --start-period will not be counted towards the maximum number of retries
# NOTE: k8s uses livenessProbe, startupProbe, readinessProbe and ignores HEALTHCHECK
HEALTHCHECK --start-period=5m --interval=10s --timeout=10s --retries=6 CMD ["/healthcheck.sh"]
### Install main dependecies
RUN chmod +x /docker-entrypoint.sh /healthcheck.sh

USER prometheus

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD        [ "--config.file=prometheus.yml" ]