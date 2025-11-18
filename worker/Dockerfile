FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN useradd -m appuser

WORKDIR /app

# pip robustness fixes
RUN python -m pip install --upgrade pip \
 && pip config set global.timeout 100 \
 && pip config set global.retries 20 \
 && pip config set global.disable-pip-version-check true \
 && pip config set global.index-url https://pypi.org/simple \
 && pip config set global.trusted-host pypi.org \
 && pip config set global.trusted-host files.pythonhosted.org

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

USER appuser

CMD ["rq", "worker", "-u", "redis://redis:6379", "webhook-jobs"]
