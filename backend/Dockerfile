FROM eclipse-temurin:21-jdk-alpine AS build
RUN apk add --no-cache maven dos2unix
WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY wait-for-it.sh .
RUN dos2unix wait-for-it.sh
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]