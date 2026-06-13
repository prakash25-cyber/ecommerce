FROM nginx:1.25-alpine

# 1. Copy your website frontend layout
COPY index.html /usr/share/nginx/html/index.html

# 2. NEW: Copy the server configuration to handle port 8080 properly
COPY default.conf /etc/nginx/conf.d/default.conf

# 3. DEVSECOPS HARDENING: Modify core system folder ownerships
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch container execution context to safe user mode
USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]