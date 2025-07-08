FROM maven:3 AS maven-build

COPY pom.xml .

RUN mvn install

FROM frankframework/frankframework:9.2.0-20250512.173626

COPY --from=maven-build target/dependency /opt/frank/drivers/

# Copy Frank!
COPY --chown=tomcat src/main/ /opt/frank/

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=60 \
	CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
