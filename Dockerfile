# Build stage
FROM node:20-alpine as build
WORKDIR /app
ENV DISABLE_ESLINT_PLUGIN=true

COPY package*.json ./
RUN npm install --no-package-lock

COPY . .
RUN npm run build


# Production stage
FROM nginx:stable-alpine

# Copy built frontend
COPY --from=build /app/build /usr/share/nginx/html

# Use your nginx.conf as server block
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Install security patches & tools
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl openssl

# Expose port
EXPOSE 80

# IMPORTANT: run as root (required for binding to port 80)
# Do NOT add a custom user here. Nginx default user=nginx is fine.
# Removing USER ensures nginx master runs as root → bind 80 OK, pid OK.

CMD ["nginx", "-g", "daemon off;"]

