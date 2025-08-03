FROM golang:1.24.0-alpine AS builder

ENV BURROW_HOME=/usr/src/Burrow/

RUN apk add --no-cache git curl \
    && git clone https://github.com/linkedin/Burrow.git $BURROW_HOME

WORKDIR $BURROW_HOME

COPY init-sh/burrow-starter.sh /usr/bin
RUN chmod +x /usr/bin/burrow-starter.sh

RUN go mod tidy && go build -o /tmp/burrow .

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y netcat-openbsd

COPY --from=builder /tmp/burrow /opt/
COPY --from=builder /usr/bin/burrow-starter.sh /usr/bin/

RUN mkdir -p /opt/logs

CMD [ "burrow-starter.sh" ]