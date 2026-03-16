FROM nginx:alpine

COPY build/web /usr/share/nginx/html

# Flutter web needs correct MIME types and single-page app routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
