FROM python:3.10-slim AS build 

RUN apt-get update && apt-get -y install libpq-dev gcc
COPY ./requirements.txt requirements.txt
RUN pip3 install --no-cache-dir --target=packages -r requirements.txt

FROM python:3.10-slim AS runtime
COPY --from=build packages /usr/lib/python3.10/site-packages
ENV PYTHONPATH=/usr/lib/python3.10/site-packages

RUN useradd -m nonroot
USER nonroot

WORKDIR /app
COPY . .
EXPOSE 8000

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["python3","manage.py", "runserver", "0.0.0.0:8000"]