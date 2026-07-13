# ---------- Build Stage ----------

FROM node:20-alpine AS builder

WORKDIR /app

# Copy only package files first (better caching)

COPY package*.json ./

# Install ALL dependencies (including dev for build tools like vite)

RUN npm ci

# Copy source code

COPY . .

# Build the app

RUN npm run build

# ---------- Production Stage ----------

FROM nginx:1.27-alpine

# Clean default nginx files

RUN rm -rf /usr/share/nginx/html/*

# Copy only built files (no node_modules = secure & small)

COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port

EXPOSE 80

# Healthcheck

HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost || exit 1

# Start nginx

CMD ["nginx", "-g", "daemon off;"]
