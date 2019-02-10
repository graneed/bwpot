FROM fluent/fluentd:latest

RUN apk --update --no-cache add ruby-bigdecimal ruby-dev build-base && \
    fluent-gem install fluent-plugin-bigquery

ADD dist/ /root/dist/

RUN mv /root/dist/fluent.conf /fluentd/etc/fluent.conf && \
    mv /root/dist/nginx_access_schema.json /fluentd/etc/nginx_access_schema.json && \
    mv /root/dist/tshark_payload_schema.json /fluentd/etc/tshark_payload_schema.json
