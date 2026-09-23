FROM python:3.12-slim

# Run as non-root user (basic hardening step you can cite in interviews)
RUN useradd -m appuser
WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

USER appuser
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
