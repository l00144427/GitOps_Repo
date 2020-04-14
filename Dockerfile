FROM ubuntu:16.04
ENTRYPOINT [ "/usr/bin/java", "-jar", "/home/ubuntu/calculator.jar" ]