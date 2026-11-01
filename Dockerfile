FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests package

FROM eclipse-temurin:17-jre-jammy
RUN groupadd --system petclinic \
    && useradd --system --gid petclinic --uid 10001 --home-dir /app --shell /usr/sbin/nologin petclinic
WORKDIR /app
COPY --from=build --chown=petclinic:petclinic /app/target/spring-petclinic-*.jar /app/app.jar
USER petclinic
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD bash -c 'echo > /dev/tcp/127.0.0.1/8080' || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
