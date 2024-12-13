# adapted from https://github.com/frison/100hellos/tree/main/smalltalk

FROM alpine:3.20
WORKDIR /prog

RUN apk add --no-cache zip gawk patch linux-headers gcc musl-dev make
RUN wget https://ftp.gnu.org/gnu/smalltalk/smalltalk-3.2.tar.xz
RUN tar -xvf smalltalk-3.2.tar.xz
RUN rm smalltalk-3.2.tar.xz

COPY support-musl.patch .
RUN patch -p0 < support-musl.patch

WORKDIR /prog/smalltalk-3.2
RUN CFLAGS=-std=gnu89 ./configure --prefix=/prog/st --disable-generational-gc --without-emacs
RUN make
RUN make install

WORKDIR /prog
COPY . .
CMD ["st/bin/gst", "-f", "main.st"]
