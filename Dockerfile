From amazonlinux:latest

WORKDIR /app

COPY app.py /app/.

RUN yum install python3 -y

CMD ["python3", "app.py"]

