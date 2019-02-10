FROM alpine:latest

RUN apk --update --no-cache add tshark

RUN mkdir /tshark && \
    mkdir /tshark/log && \
    mkdir /tshark/dump

# fluentd checks logs by line.
# set stdout buffer mode to linebuffer mode(-l).
CMD ip=`ip -4 -o a show eth0 | awk -F '[ /]+' '/global/ {print $4}'` && \
    tshark -i eth0 -p -n \
    -l \
    -f "tcp and (dst host $ip and (dst port 80 or dst port 8080 or dst port 443)) or (src host $ip and (src port 80 or src port 8080 or src port 443))" \
    -T ek \
    -w /tshark/dump/tcp.pcap \
    >> /tshark/log/tcp.json
