# Use a specific version of Ubuntu for reproducibility
FROM ubuntu:22.04

# Set maintainer information using LABEL
LABEL maintainer="xxradar <xxadar@radarhack.com>"

# Update package lists, install necessary packages, and clean up in a single layer
RUN apt-get update && \
    apt-get install -y openssl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and group for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set the working directory
WORKDIR /scripts

# Copy the scanner script into the image
COPY tlssan_scan.sh /scripts/tlssan_scan.sh

# Ensure the script is executable (though COPY preserves permissions, this is explicit)
RUN chmod +x /scripts/tlssan_scan.sh

# Download and run Aqua MicroScanner
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
ARG token
# Run MicroScanner; --continue-on-failure allows build to proceed even if issues are found
RUN /microscanner ${token} --continue-on-failure
# Remove MicroScanner after use
RUN rm -rf /microscanner

# Switch to the non-root user before setting the entrypoint
USER appuser

# Set the entrypoint for the container
ENTRYPOINT ["/scripts/tlssan_scan.sh"]
