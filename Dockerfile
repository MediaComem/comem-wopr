FROM node:20.11.0-alpine AS build

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci

COPY ./ ./
RUN npm run build

FROM ruby:3.2.3-alpine

WORKDIR /usr/src/app

RUN apk add --no-cache build-base

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY ./ ./
COPY --from=build /usr/src/app/public/ ./public/

CMD ["bundle", "exec", "ruby", "app.rb"]