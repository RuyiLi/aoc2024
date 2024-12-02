FROM alpine:3.20
WORKDIR /prog

# install odin
RUN apk add --no-cache tar clang
RUN wget -O odin.zip https://github.com/odin-lang/Odin/releases/download/dev-2024-11/odin-linux-amd64-dev-2024-11.zip
RUN unzip odin.zip
RUN tar xzf dist.tar.gz odin-linux-amd64-nightly+2024-11-04
RUN mv odin-linux-amd64-nightly+2024-11-04 odin/

# copy and build program files
COPY . .
CMD ["odin/odin", "run", "main.odin", "-file"]
