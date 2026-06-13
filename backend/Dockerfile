# Use a slim, security-patched long-term support Node layer
FROM node:20-alpine

# Set the operational context directory inside the container
WORKDIR /usr/src/app

# Copy dependency mappings first to optimize caching structures
COPY package*.json ./

# Install clean, production-only isolated dependencies
RUN npm ci --only=production

# Copy over the rest of the application source code
COPY server.js .

# DEVSECOPS HARDENING: Never run application logic as root inside clusters.
# We explicitly drop down execution context to the built-in unprivileged node user.
USER node

# Expose the designated local communication target port
EXPOSE 5000

# Start up the secure server engine
CMD ["npm", "start"]