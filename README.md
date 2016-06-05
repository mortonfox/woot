# woot - Daily deals summary and Woot-off watching scripts for Woot.com

## Introduction

`woot.rb` and `woot2.rb` are scripts that operate in two modes:

* Display daily deals from [woot.com](http://www.woot.com/) and then quit.
* Display woot.com deals, repeating at regular time intervals.

The latter is meant for watching a Woot-Off.

The reason for having two scripts is `woot.rb` uses the original Woot API,
while `woot2.rb` uses [Woot API v2](http://api.woot.com/2/), which is
currently in beta. The second script will become the main script if and when
Woot decides that Woot API v2 is no longer in beta.

## Usage

One-time mode:

    ruby woot.rb

or

    ruby woot2.rb

This command will display the main deal in every section once and then quit.

Repeated mode:

    ruby woot.rb -t 15

or

    ruby woot2.rb -t 15

This command will display the set of deals every 15 seconds until you hit
Ctrl-C to terminate it. Instead of 15, you can specify any other number N to
repeat the display every N seconds.

## Woot v2 API key

Woot API v2 takes an API key parameter on each request. A default API key is
included with the script. However, if you need your own API key, register a new
application at <https://account.woot.com/applications>.

After you have registered the application, Woot will provide two strings.
Ignore the API secret for now. Copy the API key into the line of the script
that sets the API\_KEY.
