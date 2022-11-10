sudo mkdir /usr/local/java

sudo cp /vagrant/OpenJDK11U-jdk_x64_linux_hotspot_11.0.17_8.tar.gz /usr/local/java

cd /usr/local/java

sudo tar zxvf /usr/local/java/OpenJDK11U-jdk_x64_linux_hotspot_11.0.17_8.tar.gz

sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk-11.0.17+8/bin/java" 1
