FROM nimlang/nim:2.2.0-alpine
WORKDIR /prog

COPY . .
CMD ["nim", "compile", "--hints:off", "--run", "main.nim"]
