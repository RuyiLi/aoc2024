FROM alpine:3.20
WORKDIR /prog

RUN apk add --no-cache perl

COPY . .
CMD ["perl", "main.perl"]
