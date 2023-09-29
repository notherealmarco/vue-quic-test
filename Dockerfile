FROM node:lts as builder

### Copy Vue.js code
WORKDIR /app
COPY . webui

### Build Vue.js into plain HTML/CSS/JS
WORKDIR /app/webui
RUN npm install
RUN npm run build


### Create final container
FROM nginx:stable

### Copy the (built) app from the builder image
COPY --from=builder /app/webui/dist /usr/share/nginx/html
