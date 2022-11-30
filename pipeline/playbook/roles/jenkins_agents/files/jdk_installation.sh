#!/bin/bash
cd /usr/local/java

sudo tar xvf /usr/local/java/OpenJDK11U-jdk_x64_linux_hotspot_11.0.17_8.tar.gz

sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk-11.0.17+8/bin/java" 1

return 0
