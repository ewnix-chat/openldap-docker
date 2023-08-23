# ----- Build Stage -----
FROM debian:bookworm-slim as builder

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Install the necessary build tools and libraries
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        curl \
        libdb-dev \
        libssl-dev \
        libsasl2-dev \
        libgnutls28-dev \
        libltdl-dev \
        groff-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define OpenLDAP version and download, build, and install
ENV OPENLDAP_VERSION=2.6.6

WORKDIR /tmp

RUN curl -LO ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz \
    && tar xzf openldap-${OPENLDAP_VERSION}.tgz \
    && cd openldap-${OPENLDAP_VERSION} \
    && ./configure --prefix=/usr/local/openldap \
                   --sysconfdir=/etc/ldap \
                   --localstatedir=/var/lib/ldap \
                   --enable-slapd \
    && make && make install \
    && rm -rf /tmp/*

# ----- Production Stage -----
FROM debian:bookworm-slim

# Copy the OpenLDAP binaries and libraries from the builder stage
COPY --from=builder /usr/local/openldap /usr/local/openldap

# Install any runtime dependencies
RUN apt-get update \
    && apt-get install -y \
        libdb5.3 \
        libssl3 \
        libsasl2-2 \
        libgnutls30 \
        libltdl7 \
        gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && gosu nobody true

# Expose the default slapd ports
EXPOSE 389 636

# Create user and group for openldap
RUN groupadd -g 10000 openldap \
    && useradd -u 10000 -g openldap -d /var/lib/ldap -s /bin/false openldap

# Use ENTRYPOINT for the command and CMD for its arguments
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY base-cn\=config.ldif /tmp/base-cn\=config.ldif

# Switch to openldap user after setup is complete
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["-F", "/etc/ldap/slapd.d", "-h", "ldap:/// ldaps:///", "-d", "256"]

