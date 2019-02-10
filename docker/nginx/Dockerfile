FROM nginx:alpine

RUN apk --update --no-cache add nginx-mod-http-lua

ADD dist/ /root/dist/

RUN mv /root/dist/nginx.conf /etc/nginx/nginx.conf && \
    mv /root/dist/server.key /etc/nginx/server.key && \
    mv /root/dist/server.crt /etc/nginx/server.crt && \
    mv /root/dist/default.conf /etc/nginx/conf.d/default.conf
