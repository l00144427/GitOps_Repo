FROM openjdk:15
COPY /home/ubuntu/calculator.jar /
ENTRYPOINT [ "/usr/bin/java", "-jar", "/calculator.jar" ]
