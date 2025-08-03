FROM node:18 AS builder

RUN apt-get update && apt-get install -y git

WORKDIR /app
RUN git clone https://github.com/linkedin/cruise-control-ui.git .

COPY init-sh/cc-ui-starter.sh /usr/bin
RUN chmod +x /usr/bin/cc-ui-starter.sh 

RUN npm ci
RUN npm run build

FROM ubuntu/nginx:1.26-24.10_beta

RUN apt-get update && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /usr/bin/cc-ui-starter.sh /usr/bin/cc-ui-starter.sh

CMD [ "cc-ui-starter.sh" ]