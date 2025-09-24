FROM ubuntu:22.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
  && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
  && apt-get -y install git curl wget unzip xz-utils zip libglu1-mesa \
  ca-certificates gnupg lsb-release software-properties-common \
  build-essential libssl-dev pkg-config sudo openjdk-17-jdk \
  android-tools-adb android-tools-fastboot \
  && apt-get autoremove -y \
  && apt-get clean -y

# Install official Google Android SDK
RUN mkdir -p /opt/android-sdk \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdtools.zip \
  && unzip -q /tmp/cmdtools.zip -d /opt/android-sdk \
  && rm /tmp/cmdtools.zip \
  && mv /opt/android-sdk/cmdline-tools /opt/android-sdk/cmdline-tools-temp \
  && mkdir -p /opt/android-sdk/cmdline-tools/latest \
  && mv /opt/android-sdk/cmdline-tools-temp/* /opt/android-sdk/cmdline-tools/latest/ \
  && rmdir /opt/android-sdk/cmdline-tools-temp \
  && chown -R root:root /opt/android-sdk \
  && chmod -R 755 /opt/android-sdk

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

# Create mount point for Android SDK (will be mounted from host)
RUN mkdir -p /home/$USERNAME/Android/Sdk

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME \
  && cd $FLUTTER_HOME \
  && git checkout stable \
  && $FLUTTER_HOME/bin/flutter config --no-analytics

# Set ownership for Flutter
RUN chown -R $USERNAME:$USERNAME $FLUTTER_HOME

# Create the project directory structure and Android SDK mount point
RUN mkdir -p /home/$USERNAME/projects/dartwing /home/$USERNAME/Android/Sdk \
  && chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set Android SDK environment variables and PATH
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV PATH="$PATH:/usr/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator:/opt/android-sdk/cmdline-tools/latest/bin"

# Install essential Android SDK components
RUN yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses \
  && /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager \
  "platform-tools" \
  "emulator" \
  "cmake;3.22.1" \
  "ndk;27.0.12077973" \
  "build-tools;33.0.0" \
  "build-tools;34.0.0" \
  "platforms;android-30" \
  "platforms;android-31" \
  "platforms;android-32" \
  "platforms;android-33" \
  "platforms;android-34" \
  "platforms;android-35" \
  "platforms;android-36" \
  "system-images;android-34;google_apis;x86_64" \
  && chmod -R 755 /opt/android-sdk

# Set the default user
USER $USERNAME

# Add Android SDK to user's shell profile and ADB server socket configuration
RUN echo "export ANDROID_HOME=\"/opt/android-sdk\"" >> /home/$USERNAME/.bashrc \
  && echo "export ANDROID_SDK_ROOT=\"/opt/android-sdk\"" >> /home/$USERNAME/.bashrc \
  && echo "export PATH=\"\$PATH:/usr/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator:/opt/android-sdk/cmdline-tools/latest/bin\"" >> /home/$USERNAME/.bashrc \
  && echo "export ADB_SERVER_SOCKET=tcp:host.docker.internal:5037" >> /home/$USERNAME/.bashrc

# Create compatibility directories and ensure Flutter can find tools
RUN mkdir -p /home/$USERNAME/Android/Sdk/platform-tools \
  && ln -sf /opt/android-sdk/platform-tools/adb /home/$USERNAME/Android/Sdk/platform-tools/adb \
  && ln -sf /opt/android-sdk/platform-tools/fastboot /home/$USERNAME/Android/Sdk/platform-tools/fastboot \
  && chown -R $USERNAME:$USERNAME /home/$USERNAME/Android/Sdk

WORKDIR /workspace

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
ENV DEBIAN_FRONTEND=dialog