FROM alpine:3.20
WORKDIR /prog

RUN apk add --no-cache dmd build-base

COPY . .
RUN dmd main.d
CMD ["./main"]
