Introduction
============

hiera-redis empowers Hiera to retrieve values from a Redis database.

Supported Redis types:

* set
* sorted set
* list
* string
* hash

All types can be JSON or YAML serialized but I don't see anything other than a string type being used for the job.

Configuration
=============
In hiera.yaml, the following options can be defined if needed:
<pre>
:redis:
  :password: clearp@ssw0rd        # if your Redis server requires authentication

  :port: 6380                     # unless present, defaults to 6379

  :db: 1                          # unless present, defaults to 0

  :host: db.example.com           # unless present, defaults to localhost

  :path: /tmp/redis.sock          # overrides port if unixsocket exists

  :soft_connection_failure: true  # bypass exception if Redis server is unavailable; default is false

  :deserialize: :json             # when you've serialized your data; can also be set to :yaml

  :separator: /                   # unless present, defaults to :
</pre>

Install
=======

`gem install hiera-redis hiera-puppet`

Example
=======

Add some data into your Redis database

`set Debian:foo bar`
`set common:foo baz`
`hmset pets:kitties Evil black Handsome gray`

Configure ~/.puppet/hiera.yaml

`cat <<EOF > ~/.puppet/hiera.yaml`
`> :hierarchy:`
`>   - %{operatingsytem}`
`>   - pets`
`>   - common`
`> :backends:`
`>   - redis`
`> EOF`

What is foo?

`$ hiera -c ~/.puppet/hiera.yaml foo`

What is bar?

`$ hiera -c ~/.puppet/hiera.yaml foo`

and the kitties?

`$ hiera -c ~/.puppet/hiera.yaml kitties`

hiera('Evil', nil, 'pets/kitties')`
hiera('Handsome', nil, 'pets/kitties')`

Contact
=======

* Author: Adam Kosmin c/o Reliant Security, Inc.
* Email: akosmin@reliantsecurity.com
* IRC (freenode): windowsrefund
* Myspace: no

