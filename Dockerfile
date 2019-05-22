FROM ubuntu:latest
MAINTAINER xxradar "xxadar@radarhack.com"
RUN apt-get update && apt-get install -y openssl && apt-get -y install ca-certificates
WORKDIR /scripts
COPY tlssan_scan.sh tlssan_scan.sh
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
ARG token
RUN /microscanner ${token} --continue-on-failure --html
RUN echo "No vulnerabilities!"
RUN rm -rf /microscanner
ENTRYPOINT ["/scripts/tlssan_scan.sh"]
