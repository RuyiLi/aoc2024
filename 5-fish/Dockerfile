FROM alpine:3.20
WORKDIR /prog

RUN apk add --no-cache fish

COPY . .
CMD ["fish", "main.fish"]
