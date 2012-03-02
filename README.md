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
  :port: 6398
  :host: db.example.com
</pre>

port will default to 6397 and host will default to 127.0.0.1 if left
undefined.

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
$foo = hiera('bar')
</pre>

Contact
=======

* Author: Adam Kosmin c/o Reliant Security, Inc.
* Email: akosmin@reliantsecurity.com
* IRC (freenode): windowsrefund

