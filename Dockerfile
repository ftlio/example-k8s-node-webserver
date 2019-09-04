FROM node:dubnium-alpine

WORKDIR /app
COPY . /app
RUN npm install

CMD ["/usr/local/bin/node", "index.js"]
