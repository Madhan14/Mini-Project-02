FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.config /etc/nginx/conf.d/default.conf
COPY dist/ /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
