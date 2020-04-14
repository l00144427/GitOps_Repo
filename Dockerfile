FROM openjdk:15
ENTRYPOINT [ "/usr/bin/java", "-jar", "/home/ubuntu/calculator.jar" ]