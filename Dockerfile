FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production

COPY package.json ./
RUN npm install --omit=dev

COPY . .

# Attach a Railway Volume mounted at /data and keep DATA_DIR aligned with it.
ENV DATA_DIR=/data
EXPOSE 3000
CMD ["npm", "start"]
