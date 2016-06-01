# woot - Daily deals summary and Woot-off watching scripts for Woot.com

## Introduction

```woot.rb``` and ```woot2.rb``` are scripts that operate in two modes:

* Display daily deals from [woot.com](http://www.woot.com/) and then quit.
* Display woot.com deals, repeating at regular time intervals.

The latter is meant for watching a Woot-Off.

The reason for having two scripts is ```woot.rb``` uses the original Woot API,
while ```woot2.rb``` uses [Woot API v2](http://api.woot.com/2/), which is
currently in beta. The second script will become the main script if and when
Woot decides that Woot API v2 is no longer in beta.
