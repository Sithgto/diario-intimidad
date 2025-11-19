FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache dos2unix
COPY --from=0 /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=0 /app/wait-for-it.sh /wait-for-it.sh
RUN dos2unix /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
EXPOSE 80
ENTRYPOINT ["/wait-for-it.sh"]
CMD ["backend:8080", "nginx", "-g", "daemon off;"]