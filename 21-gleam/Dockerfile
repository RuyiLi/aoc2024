FROM alpine:3.21
WORKDIR /prog

RUN apk add --no-cache erlang gleam

COPY . .
RUN mkdir src
RUN mv main.gleam src/
CMD ["gleam", "run", "--no-print-progress"]
