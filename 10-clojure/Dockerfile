FROM clojure:temurin-23-alpine
WORKDIR /prog

RUN apk add --no-cache rlwrap 

COPY . .
CMD ["clj", "-M", "main.clj"]
