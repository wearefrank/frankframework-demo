ARG FF_VERSION=latest

FROM maven as maven-build

COPY pom.xml .

RUN mvn install

FROM frankframework/frankframework:${FF_VERSION}

COPY --from=maven-build target/frank-flow*.war /usr/local/tomcat/webapps/frank-flow.war

# Copy Frank!
COPY --chown=tomcat src/main/ /opt/frank/

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=60 \
	CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
