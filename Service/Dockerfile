FROM python:3.8-alpine

RUN mkdir /app

ADD . /app

WORKDIR /app

RUN pip install -r requirements.txt

CMD ["python", "ingest_firehose_stream.py"]