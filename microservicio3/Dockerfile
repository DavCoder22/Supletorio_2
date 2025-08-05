# Use the official Node.js 16 image as the base image
FROM node:16-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code
COPY . .

# Copy the environment file (make sure to create a .env file before building)
# Note: In production, you might want to use environment variables directly in your deployment
# or use a secret management solution instead of including a .env file in the image
COPY .env .

# Expose the port the app runs on
EXPOSE 3002

# Command to run the application
CMD ["node", "src/index.js"]
