Introduction
============

hiera-redis empowers
[Hiera](http://projects.puppetlabs.com/projects/hiera) to retrieve values from a Redis database.

Supported Redis types:

* set
* sorted set
* list
* string
* hash

All types can be JSON or YAML serialized but I don't see anything other than a string type being used for the job.

Configuration
=============

The following options can be specified in hiera.yaml:
<pre>
:redis:
  :password: clearp@ssw0rd        # if your Redis server requires authentication
  :port: 6380                     # unless present, defaults to 6379
  :db: 1                          # unless present, defaults to 0
  :host: db.example.com           # unless present, defaults to localhost
  :path: /tmp/redis.sock          # overrides port if unixsocket exists
  :soft_connection_failure: true  # bypass exception if Redis server is unavailable; default is false
  :separator: /                   # unless present, defaults to :

  :deserialize: :json             # Try to deserialize; both :yaml and :json are supported
                                  # When :json is used and JSON::ParseError is raised, gracefully fall
                                  # back to returning the original value. This is needed to work around
                                  # JSON.parse('foo'.to_json)
</pre>

Install
=======

`gem install hiera-redis`

Example
=======

Add some data into your Redis database

`set Debian:foo bar`

`set common:foo baz`

`hmset pets:kitties Evil black Handsome gray`

Configure ~/.puppet/hiera.yaml

<pre>
:hierarchy:
  - %{operatingsytem}
  - pets
  - common
:backends:
  - redis
</pre>

What is foo?

`$ hiera -c ~/.puppet/hiera.yaml foo`

What is bar?

`$ hiera -c ~/.puppet/hiera.yaml bar`

and the kitties?

`$ hiera -c ~/.puppet/hiera.yaml kitties`

Related Information
===================
See the
[hiera-resources](http://github.com/reliantsecurity/hiera-resources)
documentation for an example of using hiera-redis with serialized
strings stored in Redis (JSON and YAML supported).

Contact
=======

* Author: Adam Kosmin c/o Reliant Security, Inc.
* Email: akosminATreliantsecurity.com
* IRC (freenode): windowsrefund

