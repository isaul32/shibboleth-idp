FROM jetty:10-jdk11-slim
LABEL maintainer="sauli.anto@gmail.com"
USER root
ENV IDP_VERSION=4.1.5 \
    IDP_HASH=8173a2f5e05ec75e7b6ccbbab45639decb3286ecd705f1350a75a2b551096596
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN curl -LJO https://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-$IDP_VERSION.tar.gz \
    && echo "$IDP_HASH shibboleth-identity-provider-$IDP_VERSION.tar.gz" | sha256sum -c -
RUN tar -zxvf shibboleth-identity-provider-$IDP_VERSION.tar.gz \
    && rm shibboleth-identity-provider-$IDP_VERSION.tar.gz \
    && cd shibboleth-identity-provider-$IDP_VERSION \
    && ./bin/install.sh \
    -Didp.src.dir /opt/shibboleth-identity-provider-$IDP_VERSION \
    -Didp.target.dir /opt/shibboleth-idp \
    -Didp.host.name idp.localhost \
    -Didp.keystore.password s3cret \
    -Didp.sealer.password s3cret \
    -Didp.entityID https://idp.localhost/idp/shibboleth \
    -Didp.scope localdomain \
    && chown -R jetty:jetty /opt/shibboleth-idp \
    && rm -fr shibboleth-identity-provider-$IDP_VERSION
# WORKDIR /opt/shibboleth-idp
# # TODO customization
# RUN ./bin/build.sh -Didp.target.dir /opt/shibboleth-idp
RUN ln -s /opt/shibboleth-idp/war/idp.war /var/lib/jetty/webapps
USER jetty
WORKDIR /var/lib/jetty
