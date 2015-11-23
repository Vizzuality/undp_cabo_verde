# UNDP Cabo Verde #

[![Build Status](https://travis-ci.org/Vizzuality/undp_cabo_verde.svg?branch=staging)](https://travis-ci.org/Vizzuality/undp_cabo_verde) [![Code Climate](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/badges/gpa.svg)](https://codeclimate.com/github/Vizzuality/undp_cabo_verde) [![Test Coverage](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/badges/coverage.svg)](https://codeclimate.com/github/Vizzuality/undp_cabo_verde/coverage)

## REQUIREMENTS ##

  - **Ruby version:** 2.2.2
  - **PostgreSQL**

## SETUP ##

**Just execute the script file in `bin/setup**

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

### Install gems: ###

    bundle install

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

## BEFORE CREATING A PULL REQUEST

Please check all of [these points](https://github.com/Vizzuality/undp_cabo_verde/blob/master/CONTRIBUTING.md).

## API ##

## DEPLOYMENT ##

### Heroku ###

**Automatic deploys from  staging are enabled**

Every push to staging will deploy a new version of this app. Deploys happen automatically: be sure that this branch in GitHub is always in a deployable state and any tests have passed before you push.

Heroku wait for CI to pass before deploy.