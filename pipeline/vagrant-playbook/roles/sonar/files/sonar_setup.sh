#!/bin/bash

chdir /usr/local

unzip sonar.zip

mv sonarqube-9.7.1.62043 sonar

chown -R sonar:sonar /usr/local/sonar

mkdir -p /data/sonar

chown -R sonar:sonar /data/sonar