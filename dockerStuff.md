# Build image
docker buildx build --platform=linux/amd64 -t abra . 

# List available images
docker images

# Run image in interactive way (alpine)
docker run -it abra ./gradlew --no-build-cache --no-daemon assembleDebug
docker run -it --memory="4g" abra ./gradlew --no-build-cache --no-daemon -Dkotlin.compiler.execution.strategy="in-process" assembleDebug

-Dkotlin.compiler.execution.strategy="in-process"

# List all running containers
docker container ls

# Stop Running containers
docker stop container

# Remove image
docker image rm -f IMAGE

# LIST SDKMANAGER PACKAGES
sdkmanager --list | grep system-images
sdkmanager --list | grep build-tools

# Command tools android
set ANDROID_HOME=/android_sdk
wget -P /tmp https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip /tmp/commandlinetools-linux-9477386_latest.zip -d $ANDROID_HOME
mv $ANDROID_HOME/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
yes | sdkmanager "build-tools;34.0.0-rc3" "platform-tools" "platforms;android-31"
echo "sdk.dir=$ANDROID_HOME" >  '/app/local.properties'


FROM ubuntu:22.04
WORKDIR /app
COPY . .
ARG ANDROID_HOME=/android_sdk
RUN apt-get update -y && apt-get install -y openjdk-11-jdk && apt-get install -y unzip && apt-get install -y wget
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN wget -P /tmp https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip /tmp/commandlinetools-linux-9477386_latest.zip -d $ANDROID_HOME
RUN mkdir $ANDROID_HOME/cmdline-tools/latest
RUN mv $ANDROID_HOME/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest || true
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
RUN yes | sdkmanager "build-tools;34.0.0-rc3" "platform-tools" "platforms;android-31"
RUN echo "sdk.dir=$ANDROID_HOME" >  '/app/local.properties'


#FROM alpine:3.14
#WORKDIR /app
#COPY . .
#ARG ANDROID_HOME=/android_sdk
#RUN apk update && apk add openjdk11
#RUN wget -P /tmp https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
#RUN unzip /tmp/commandlinetools-linux-9477386_latest.zip -d $ANDROID_HOME
#RUN mkdir $ANDROID_HOME/cmdline-tools/latest
#RUN mv $ANDROID_HOME/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest || true
#ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
#RUN yes | sdkmanager "build-tools;34.0.0-rc3" "platform-tools" "platforms;android-31"
#RUN echo "sdk.dir=$ANDROID_HOME" >  '/app/local.properties'

#FROM ubuntu:22.04
#WORKDIR /app
#COPY . .
#ARG ANDROID_HOME=/android_sdk
#RUN apt-get update -y && apt-get install -y openjdk-11-jdk && apt-get install -y unzip && apt-get install -y wget
#RUN apt-get install -y locales
#RUN locale-gen en_US.UTF-8
#ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
#RUN wget -P /tmp https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
#RUN unzip /tmp/commandlinetools-linux-9477386_latest.zip -d $ANDROID_HOME
#RUN mkdir $ANDROID_HOME/cmdline-tools/latest
#RUN mv $ANDROID_HOME/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest || true
#ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
#RUN yes | sdkmanager "build-tools;34.0.0-rc3" "platform-tools" "platforms;android-31"
#RUN echo "sdk.dir=$ANDROID_HOME" >  '/app/local.properties'





name: Run instrumentation tests

on:
  workflow_dispatch:

jobs:
  instrumentation-tests:
    name: Instrumentation tests
    runs-on: self-hosted
    timeout-minutes: 30
    steps:
      - name: List connected usb devices
        run: lsusb

      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: "11"

      - name: Setup Gradle
        uses: gradle/gradle-build-action@v2

      - name: Run instrumentation
        run: ./gradlew --no-daemon connectedDebugAndroidTest


name: Run instrumentation tests

on:
  workflow_dispatch:

jobs:
  instrumentation-tests:
    name: Instrumentation tests
    runs-on: self-hosted
    timeout-minutes: 30
    steps:
      - name: List connected usb devices
        run: lsusb

      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Build docker image
        run: podman build -t abra .

      - name: Run container
        run: podman run -it abra ./gradlew --no-build-cache --no-daemon clean assembleDebug