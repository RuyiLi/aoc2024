FROM alpine:3.20
WORKDIR /prog

# install nasm
RUN apk add --no-cache nasm binutils

# copy and build program files
COPY . .
RUN nasm -f elf64 main.asm
RUN ld main.o -o main
CMD ["./main"]
