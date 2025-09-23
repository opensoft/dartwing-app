FROM ubuntu:22.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
  && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
  && apt-get -y install git curl wget unzip xz-utils zip libglu1-mesa \
  ca-certificates gnupg lsb-release software-properties-common \
  build-essential libssl-dev pkg-config sudo openjdk-17-jdk \
  && apt-get autoremove -y \
  && apt-get clean -y

# Get host user info (passed as build args)
ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=brett

# Create user with matching UID/GID and username to avoid permission issues
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -ms /bin/bash $USERNAME \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Install Android SDK
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK_ROOT="$ANDROID_HOME"
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Create Android SDK directory
RUN mkdir -p $ANDROID_HOME/cmdline-tools

# Download and install Android command line tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O /tmp/cmdline-tools.zip \
  && unzip -q /tmp/cmdline-tools.zip -d /tmp \
  && mv /tmp/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
  && rm /tmp/cmdline-tools.zip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME \
  && cd $FLUTTER_HOME \
  && git checkout stable \
  && $FLUTTER_HOME/bin/flutter config --no-analytics

# Install Android SDK components and accept licenses
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses \
  && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" \
  && chown -R $USERNAME:$USERNAME $FLUTTER_HOME $ANDROID_HOME

# Set the default user
USER $USERNAME
WORKDIR /workspace

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
ENV DEBIAN_FRONTEND=dialog