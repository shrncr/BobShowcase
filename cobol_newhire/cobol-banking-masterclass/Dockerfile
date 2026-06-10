FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gnucobol \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN make all

CMD ["make", "run-batch"]
