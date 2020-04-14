FROM ubuntu:16.04
RUN pwd
RUN ls -lh .
COPY /home/ubuntu/calculator.jar /home/ubuntu
RUN ls -lh /home/ubuntu
ENTRYPOINT [ "java", "-jar", "/home/ubuntu/calculator.jar" ]