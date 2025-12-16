# Simple Dockerfile for SCM Simulation
FROM alpine:latest
WORKDIR /app
COPY . .
# This command simulates the "build" process
RUN echo "Building Convocation Robe Application..."
# This command runs when the container starts
CMD ["echo", "Convocation App v1.0.0 Started Successfully"]