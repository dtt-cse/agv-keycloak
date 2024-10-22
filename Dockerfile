FROM quay.io/keycloak/keycloak:18.0.0

# ENV KEYCLOAK_USER=admin
# ENV KEYCLOAK_PASSWORD=MRP_Project_v1.0
ENV PATH="/opt/keycloak/bin:${PATH}"
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=MRP_Project_v1.0
ENV KC_PROXY=edge
# ENV DB_VENDOR=h2
# ENV DB_USER=admin
# ENV DB_PASSWORD=MRP_Project_v1.0
# ENV DB_DATABASE=keycloak

# Defaults in 15.0.2:
# EXPOSE 8080
# EXPOSE 8443
# ENTRYPOINT ["/opt/jboss/tools/docker-entrypoint.sh"]
# CMD ["-b" "0.0.0.0"]

# This instance is configured as standalone, as defined in:
# /opt/jboss/tools/build-keycloak.sh

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]