FROM alpine

ENV LANG="en_US.UTF-8"
ENV TZ=Asia/Shanghai
EXPOSE 4000

RUN set -x \
    && apk add --no-cache perl perl-dbi perl-dbd-mysql perl-io-socket-ssl perl-term-readkey tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

COPY bin/goInception /goInception
COPY bin/pt-online-schema-change /usr/local/bin/pt-online-schema-change
COPY config/config.toml.default /etc/config.toml

RUN wget -O /tmp/gh-ost.tar.gz https://github.com/github/gh-ost/releases/download/v1.1.6/gh-ost-binary-linux-amd64-20231207144046.tar.gz \
    && tar -xzf /tmp/gh-ost.tar.gz -C /usr/local/bin/ \
    && rm -f /tmp/gh-ost.tar.gz \
    && chmod +x /usr/local/bin/gh-ost \
    && chmod +x /usr/local/bin/pt-online-schema-change

ENTRYPOINT ["/usr/local/bin/dumb-init", "/goInception", "--config=/etc/config.toml"]
