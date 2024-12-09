FROM alpine:3.20
WORKDIR /prog

RUN apk add --no-cache tar xz
RUN wget -O zig.tar.xz https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz
RUN tar xf zig.tar.xz zig-linux-x86_64-0.13.0
RUN mv zig-linux-x86_64-0.13.0 zig/

COPY . .
CMD ["zig/zig", "run", "main.zig"]
