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

