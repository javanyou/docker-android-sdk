FROM openjdk:8-jdk

# Add default master user
RUN useradd --create-home --no-log-init --shell /bin/bash -ou 1000 -g 0 master
RUN adduser master sudo

USER root

# Install git lfs support.
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

RUN apt-get -qq update && apt-get install -qqy git-lfs cppcheck ssh file make cmake ccache lib32stdc++6 lib32z1 lib32z1-dev build-essential && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install git lfs support.
RUN git lfs install

# install android sdk
ENV VERSION_SDK_TOOLS "3859397"
ENV ANDROID_HOME="/opt/android/android-sdk-linux"

RUN mkdir -p ${ANDROID_HOME}  && curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > ${ANDROID_HOME}/sdk.zip && \
    unzip ${ANDROID_HOME}/sdk.zip -d ${ANDROID_HOME} && \
    rm -v ${ANDROID_HOME}/sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# accept android license for sdk.
RUN mkdir -p /root/.android &&  touch /root/.android/repositories.cfg
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update && \
  (while sleep 3; do echo "y"; done) | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;28.0.3" "build-tools;29.0.0" \
  "extras;android;m2repository" "extras;google;m2repository" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
  "platform-tools" "platforms;android-28" "platforms;android-29" "cmake;3.6.4111459"

# Android NDK
# TODO: Use specified NDK version. Use ndk r14b as default.
ENV ANDROID_NDK_VERSION r16b
ENV ANDROID_NDK_HOME="${ANDROID_HOME}/ndk-bundle"

# download
RUN mkdir /opt/android-ndk-tmp && \
    cd /opt/android-ndk-tmp && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# uncompress
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# remove temp dir
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /opt/android-ndk-tmp

# ---- End Android NDK.
RUN echo "SDK Manager Finish."

# Gralde
ENV GRADLE_VERSION 5.1.1
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-all.zip  \
	&& unzip gradle-${GRADLE_VERSION}-all.zip -d ${ANDROID_HOME}  \
	&& rm -rf gradle-${GRADLE_VERSION}-all.zip
ENV GRADLE_HOME ${ANDROID_HOME}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH

# Configure PMD
RUN mkdir /opt/pmd && \
    cd /opt/pmd && \
    wget -q https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.8.0/pmd-bin-6.8.0.zip && \
# uncompress
    unzip -q pmd-bin-6.8.0.zip && \
    rm pmd-bin-6.8.0.zip

ENV PMD_HOME=/opt/pmd/pmd-bin-6.8.0

# Update ENV PATH
ENV PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}:${PATH}"

#USER master
