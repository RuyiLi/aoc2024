FROM freepascal/fpc:3.2.2-alpine-3.19-minimal
WORKDIR /prog

COPY . .
RUN fpc main.pas
CMD ["./main"]
