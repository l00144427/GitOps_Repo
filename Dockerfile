FROM openjdk:15
COPY calculator.jar /
ENTRYPOINT [ "/usr/bin/java", "-jar", "/calculator.jar" ]
