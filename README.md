# "Charge Customer by Direct Debit" for Alexa

Collect money your friends owe you with your voice using the [GoCardless API](https://developer.gocardless.com).

## TODO

* Add support for OAuth (requires configuration in Alexa, and then fetching the access token from the request)

## Preparing your local environment

1. Install the application's dependencies with `bundle`
2. Make a copy of `.env.example` into `.env`, and fill in your Alexa application ID (obtained when you create your skill [here](https://developer.amazon.com/edw/home.html#/skill/create/)) and your GoCardless access token (created from your Dashboard [here](https://manage.gocardless.com/developers/access-tokens/create)).
3. Run the application with `heroku local` (which will use the included `Procfile`).

## Configuring with Alexa

You can create your Alexa skill on the Amazon site [here](https://developer.amazon.com/edw/home.html#/skill/create/)).

For the intent schema and sample utterances you'll need to provide, see `intent_schema.json` and `sample_utterances.txt`.

## Deploying

This application is ready to deploy to Heroku. Simply create an application, push it up, and set the `GOCARDLESS_ACCESS_TOKEN` and `ALEXA_APPLICATION_ID` environment variables with `heroku config:set`.

## Contributing

Pull requests are welcomed.

When making any changes, make sure you write tests, ensure them and the existing tests are passing, and check your code conforms to good Ruby style with Rubocop:

```bash
bundle exec rspec spec
bundle exec rubocop
```

The tests will automatically run in [Travis](https://travis-ci.org/).
