FROM alpine:latest

RUN apk --update --no-cache add git python3

RUN git clone https://github.com/morihisa/WOWHoneypot.git /opt/wowhoneypot

EXPOSE 8080

WORKDIR /opt/wowhoneypot

CMD ["python3", "wowhoneypot.py"]
