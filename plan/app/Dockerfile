FROM python:3

RUN pip install --no-cache-dir redis flask
ADD app.py /opt/
WORKDIR /opt

ENV FLASK_APP=app.py
ENTRYPOINT ["/usr/local/bin/flask"]
CMD ["run", "--host=0.0.0.0"]
