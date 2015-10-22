# UNDP Cabo Verde #

[![Build Status](https://travis-ci.org/Vizzuality/undp_cabo_verde.svg?branch=develop)](https://travis-ci.org/Vizzuality/undp_cabo_verde)

## Requirements ##

  **Ruby version:** mri 2.2.2

## SETUP ##

Just execute the script file in bin/setup

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
  Run all: 
  ```ruby
    rake
  ```

## API ## 

## DEPLOYMENT ##

### Heroku ###
