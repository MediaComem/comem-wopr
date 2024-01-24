FROM node:20.11.0-alpine AS build

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci

COPY . ./
RUN npm run build

FROM ruby:3.3.0

WORKDIR /usr/src/app

RUN apt update -y && apt install -y build-essential && apt clean

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
COPY --from=build /usr/src/app/public/ ./public/

CMD ["bundle", "exec", "ruby", "app.rb"]