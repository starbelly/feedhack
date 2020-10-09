feedhack
=====

An OTP application suite - a simple example

Build
-----

    $ rebar3 compile


Usage
-----

From the release root :

    $ rebar3 release
    $ ./_build/default/rel/feedhack/bin/feedhack start

You may now hit the REST api like so:

    # Get top 50
    $ curl -i -H "Accept: application/json" http://localhost:3000/api/v1/top

    # Get a specific top story
    $ curl -i -H "Accept: application/json" http://localhost:3000/api/v1/top/208506788

    # Basic Pagination
    $ curl -i -H "Accept: application/json" http://localhost:3000/api/v1/top?page=1

You may also connect with a proper websocket client. Here is an example using wscat:

```
wscat -c ws://127.0.0.1:3000/ws                                           324ms  Mon Sep  9 22:24:22 2019
connected (press CTRL+C to quit)
< [{"by":"donohoe","descendants":159,"id":20920753,"kids":[20921734,20922115,20921165,20921394,20921524,20921961,20921342,20922248,20922979,20922128,20924486,20923171,20923471,20923999,20922347,20922050,20924250,20923534,20921765,20922739,20922888,20921508,20924023,20923725,20923428],"score":693,"time":1568052935,"title":"9th Circuit holds that scraping a public website does not violate the CFAA [pdf]","type":"story","url":"http://cdn.ca9.uscourts.gov/datastore/opinions/2019/09/09/17-16783.pdf"},{"by":"jonkratz","descendants":538,"id":20919958,"kids":[20920494,20920155,20921484,20924548,20920185,20923115,20920303,20922809,20921668,20920160,20920615,20920360,20924603,20920756,20920119,20920156,20920203,20920157,20923923,20921578,20920377,20922154,20921770,20923653,20921200,20920911,20922930,20922869,20922319,20921198,2092227
...
]
<
```

