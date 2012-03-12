Introduction
============

hiera-redis empowers Hiera to retrieve values from a Redis database.

Supported data types:

* set
* sorted set
* list
* string
* hash

This code assumes your Redis keys are separated with :

Configuration
=============
In hiera.yaml, the folowing options can be defined if needed:
<pre>
:redis:
  :password: clearp@ssw0rd
  :port: 6380
  :db: 1
  :host: db.example.com
  :path: /tmp/redis.sock
</pre>

If used, path takes a higher priority over port/host values.

default values:

* password: nil
* port: 6379
* host: localhost
* path: nil
* db: 0

Install
=======
<pre>
gem install hiera-redis
</pre>

Example
=======

Add a string key/value pair to Redis

<pre>
set Debian:foo bar
</pre>

Configure hiera.yaml

<pre>
:hierarchy:
  - %{operatingsytem}
:backends:
  - redis
</pre>

Now in your Puppet manifest...

<pre>
$foo = hiera('foo')
</pre>

Contact
=======

* Author: Adam Kosmin c/o Reliant Security, Inc.
* Email: akosmin@reliantsecurity.com
* IRC (freenode): windowsrefund
* Myspace: yea right!

