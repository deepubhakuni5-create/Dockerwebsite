FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY . /usr/share/nginx/html

RUN sed -i 's/listen\s*80;/listen 6765;/' /etc/nginx/conf.d/default.conf

EXPOSE 6765

CMD ["nginx", "-g", "daemon off;"]
