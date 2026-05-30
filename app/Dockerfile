# Use official Node.js Alpine image for a lightweight build
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install production dependencies only
RUN npm install --only=production

# Copy application source code
COPY . ./

# Expose the application port
EXPOSE 3000

# Start the application
CMD [ "node", "server.js" ]
