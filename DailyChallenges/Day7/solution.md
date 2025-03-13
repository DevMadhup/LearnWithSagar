- Dockerfile
```bash
# Use Alpine-based Python image
FROM python:3.12-alpine

# Working directory
WORKDIR /app

# Copy code
COPY . .

# Run Tests
RUN pip install --upgrade flask
RUN pip install '.[test]'
RUN pytest

# Install Dependencies
RUN pip install -e .

# Expose port
EXPOSE 5000

# Run the app
RUN flask --app flaskr init-db
ENTRYPOINT ["flask", "--app", "flaskr", "run", "--host=0.0.0.0", "--debug"]
```
