#Math
[![Code Climate](https://codeclimate.com/github/neiltron/math.png)](https://codeclimate.com/github/neiltron/math)

### Requirements

  Ruby 1.9.3+

  MongoDB


### Setup

  Clone the repository: `git clone git@github.com:neiltron/math.git`

  Configure via [environment variables](./#configuration).

  `bundle install && bundle exec rackup`


### Configuration

  Math expects the following environment variables to be set.

| Variable Name         | Description |
------------------------|-------------
| MATH_DOMAIN           | The root host used in links and emails throughout the site. Examples: 'http://yourdomain.com' or 'http://localhost:999' |
| SESSION_SECRET        | A secret key for session cookies. |
| SMTP_HOST             | |
| SMTP_PORT             | |
| SMTP_USER             | |
| SMTP_PASS             | |
| SMTP_DOMAIN           | |
| NEW_RELIC_LICENSE_KEY | [optional] |
| NEW_RELIC_APP_NAME    | [optional] |
| MONGOHQ_URL           | MongoHQ connection URL. |


### Creating Clients

  There is a built in web interface, but you can also create external clients that authenticate via OAuth. These can be anything from native mobile apps to command-line scripts that do nothing but harvest data and post to Math.

  To register a client, visit http://yourserver.com/developer

  Once you've created a client, you can use the provided client id and secret token to authorize users and execute api calls on their behalf.
