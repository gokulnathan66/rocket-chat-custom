FROM node:22

# Set working directory
WORKDIR /app

# Copy the Rocket.Chat tarball into the container
COPY rocket.chat.tgz /app/

# Extract and install dependencies
RUN tar -xzf rocket.chat.tgz \
  && mv bundle Rocket.Chat \
  && cd Rocket.Chat/programs/server \
  && npm install

WORKDIR /app/Rocket.Chat

# Copy and prepare start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["bash", "/app/start.sh"]