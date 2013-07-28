Math
====

# Requirements

  Ruby 1.9.3+
  MongoDB


# Setup

  Clone this repo
  Configure via ENV vars
  bundle install
  bundle exec rackup

# Creating Clients

  There is a built in web interface, but you can also create external clients that authenticate via OAuth. These can be anything from native mobile apps to command-line scripts that do nothing but harvest data and post to Math.

  To register a client, visit http://yourserver.com/developer

  Once you've created a client, you can use the provided client id and secret token to authorize users and execute api calls on their behalf.