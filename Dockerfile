ARG FF_VERSION=latest

FROM maven as maven-build

COPY pom.xml .

RUN mvn install

FROM frankframework/frankframework:${FF_VERSION}

COPY --from=maven-build target/frank-flow*.war /usr/local/tomcat/webapps/frank-flow.war

# Copy dependencies
COPY --chown=tomcat lib/server/ /usr/local/tomcat/lib/
COPY --chown=tomcat lib/webapp/ /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Copy database connection settings
COPY --chown=tomcat src/main/webapp/META-INF/context.xml /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Copy Frank!
COPY --chown=tomcat src/main/ /opt/frank/
COPY --chown=tomcat src/test/ /opt/frank/

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=60 \
	CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
