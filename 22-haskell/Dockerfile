FROM haskell:9.8.4-slim-bullseye
WORKDIR /prog

RUN stack install unordered-containers

COPY . .
RUN stack ghc main.hs
CMD ["./main"]
