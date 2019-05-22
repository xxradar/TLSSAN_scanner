FROM ubuntu:latest
MAINTAINER xxradar "xxadar@radarhack.com"
RUN apt-get update && apt-get install -y openssl
WORKDIR /scripts
COPY tlssan_scan.sh tlssan_scan.sh
ENTRYPOINT ["/scripts/tlssan_scan.sh"]
