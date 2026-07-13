# ---------- Build Stage ----------

FROM node:20-alpine AS builder

# Set working directory

WORKDIR /app

# Install dependencies (only package files first for caching)

COPY package*.json ./
RUN npm ci --omit=dev

# Copy source code

COPY . .

# Build the application

RUN npm run build

# ---------- Production Stage ----------

FROM nginx:1.27-alpine

# Remove default nginx static files

RUN rm -rf /usr/share/nginx/html/*

# Copy build output from builder stage

COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config (optional)

# Uncomment if you have one

# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port

EXPOSE 80

# Health check (optional but recommended)

HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost || exit 1

# Start nginx

CMD ["nginx", "-g", "daemon off;"]
