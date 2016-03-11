# UNDP Cabo Verde #

[![Build Status](https://travis-ci.org/Vizzuality/undp_cabo_verde.svg?branch=develop)](https://travis-ci.org/Vizzuality/undp_cabo_verde) [![Code Climate](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/badges/gpa.svg)](https://codeclimate.com/github/Vizzuality/undp_cabo_verde) [![Test Coverage](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/badges/coverage.svg)](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/coverage)

## REQUIREMENTS ##

  - **Ruby version:** 2.2.2
  - **PostgreSQL**

## SETUP ##

**Just execute the script file in `bin/setup`**

  Depends on UNDP Cabo Verde [repository](https://github.com/Vizzuality/undp_cabo_verde)

  Create .env file with:

```
  RACK_ENV=development
  GMAIL_DOMAIN=gmail.com
  GMAIL_USERNAME=abc@gmail.com
  GMAIL_PASSWORD=your_password
  EMAIL=your_sender_email
  SECRET_KEY=abc # Run 'rake secret' to generate one
```

  More .env options:

```
  ACCESS=public - "enable Auth::Basic with user and password"
  ACCESS_USER=xxx
  ACCESS_PASSWORD=xxx
  CODECLIMATE_REPO_TOKEN=xxx - "please ask for token"
  FORCE_NON_SSL=true - "true or false"
  DEV_CACHE=enabled - "enable cache store on development"
```

### Install gems: ###

    bundle install

### Load sample data: ###

    rake db:seed_fu

### Setup memcached store: ###

  Installing memcached on OS X with Homebrew

```
  $ brew update
  $ brew doctor
  $ brew install memcached

  Run memcached server:
  $ memcached -p 11215 -vv

  Flush:
  $ echo 'flush_all' | nc localhost 11215
```

### Run application: ###

    foreman start

## TEST ##

  Run rspec:

```ruby
  bin/rspec
```
  Run teaspoon:

```ruby
  rake teaspoon
```
  Run cucumber:

```ruby
  rake cucumber
```
  Run all (cucumber, spec):

```ruby
  rake
```

capybara-webkit depends on a WebKit implementation from Qt (version >= 4.8), a cross-platform development toolkit. You'll need to download the Qt libraries to build and install the gem. [more](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)

OS X Mavericks:

    brew update
    brew install qt

In cucumber, tag scenarios with '@javascript' to run them using a headless WebKit browser.

In RSpec, use the 'js: true' flag. See the [capybara documentation](http://rubydoc.info/gems/capybara#Using_Capybara_with_RSpec) for more information about using capybara with RSpec.

## BEFORE CREATING A PULL REQUEST

Please check all of [these points](https://github.com/Vizzuality/undp_cabo_verde/blob/master/CONTRIBUTING.md).

## API ##

### SAMPLE ###

  Getting a list of enabled actors

    curl "http://localhost:5000/api/actors" -X GET \
    -H "Accept: application/json; application/gfwc-v1+json" \
    -H "Content-Type: application/json"

  Getting a specific actor

    curl "http://localhost:5000/api/actors/1" -X GET \
    -H "Accept: application/json; application/undp-cabo-verde-v1+json" \
    -H "Content-Type: application/json"

### API DOCUMENTATION ###

   For API documentation visit http://localhost:5000/api

   Generate the docs!

```ruby
  rake docs:generate
```

### Favourites Feature ###

Sample for favourites links implementation on BO

1. Add to the top of the controller that you wish to add to favourites feature:
   include FavouriteActions
   before_action :current_object,  only: [:create_favourite, :destroy_favourite]
2. on controller bottom in private section define current_object like:
   def current_object
     @object = Actor.find(params[:id])
   end
3. Define in abilities like:
   can [:create_favourite, :destroy_favourite], ::Actor
4. Define the routes like:
   resources :actors do
     post   'create_favourite',  on: :member
     delete 'destroy_favourite', on: :member
   end
5. Add to your template the partial for favourites links:
   div
     span.data
       - if current_user
         div id="#{actor.id}-favourites-buttons"
           = render partial: 'shared/favourites_buttons', locals: { object: actor }


## DEPLOYMENT ##

### Heroku ###

**Automatic deploys from  staging are enabled**

Every push to staging will deploy a new version of this app. Deploys happen automatically: be sure that this branch in GitHub is always in a deployable state and any tests have passed before you push.

Heroku wait for CI to pass before deploy.
