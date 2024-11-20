###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:18-alpine As Development
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
RUN npm i
COPY --chown=node:node . .
USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:18-alpine As build
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .
RUN npm run build
# RUN npm i --only=production && npm cache clean --force
RUN npm cache clean --force
USER node

###################
# PRODUCTION
###################

FROM node:18-alpine As production
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/.next ./.next
COPY --chown=node:node --from=build /usr/src/app/public ./public
CMD npx next start