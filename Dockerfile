FROM openjdk:8-jdk

# Install git lfs support.
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

RUN apt-get -qq update && apt-get install -qqy git-lfs cppcheck ssh file make ccache lib32stdc++6 lib32z1 lib32z1-dev \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
  (while sleep 3; do echo "y"; done) | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;26.0.0" "build-tools;25.0.3" \
  "extras;android;m2repository" "extras;google;m2repository" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
  "platform-tools" "platforms;android-26" "platforms;android-25" "ndk-bundle" "cmake;3.6.4111459"

RUN echo "SDK Manager Finish."
ENV ANDROID_SDK_HOME="${ANDROID_HOME}"
ENV ANDROID_NDK_HOME="${ANDROID_HOME}/ndk-bundle"
ENV PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}:${PATH}"

