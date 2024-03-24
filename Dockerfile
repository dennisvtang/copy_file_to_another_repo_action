FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add bash git rsync

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
