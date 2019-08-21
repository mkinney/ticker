
# Part 1: Build the app using Maven
FROM maven:3.6.0-jdk-8-alpine

## download dependencies
ADD pom.xml /
ADD ./src/assembly/zip.xml /src/assembly/zip.xml
RUN mvn verify clean
## build after dependencies are down so it wont redownload unless the POM changes
ADD ./src /src
RUN mvn package


# Part 2: use the ZIP file used in the first part and copy it across ready to RUN
FROM openjdk:8-jdk-alpine
WORKDIR /root/

# setup container os
RUN apk add --no-cache ttf-dejavu unzip

## COPY packaged ZIP file
COPY --from=0 /target/ethfinance-ticker-zip.zip app.zip
RUN unzip app.zip && rm app.zip

# use ash instead of bash
ENTRYPOINT java -cp .:lib/* org/ethfinance/ticker/EntryKt $* ${SUBREDDIT} ${USERNAME} ${PASSWORD} ${APP} ${SECRET} ${CONFIGREPO}
