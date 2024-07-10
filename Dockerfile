FROM python:3.8-slim as build

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

RUN set -ex \
    && flake8 . \
    && coverage run manage.py test \
    && coverage report \
    && bandit -r . \
    && safety check

FROM python:3.8-slim as production

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY --from=build /app /app

EXPOSE 8000

COPY ./docker/gunicorn_conf.py /gunicorn_conf.py
RUN groupadd -r django \
    && useradd -r -g django django \
    && chown -R django /app \
    && chmod +x /gunicorn_conf.py

USER django

CMD ["gunicorn", "--config", "/gunicorn_conf.py", "kubernetes_event.wsgi:application"]
