Introduction
============

Version 0.2.0

hiera-redis empowers Hiera to retrieve values from a Redis database.

Supported data types:

* set
* sorted set
* list
* string
* hash (ability to fetch complete hash or a specific value; see below)

This code assumes your Redis keys are separated with :

Configuration
=============
In hiera.yaml, the following options can be defined if needed:
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

Create a dummy module in order to load the hiera functions

`mkdir -p /tmp/modules/foo/lib/puppet/parser`  
`cd /tmp/modules/foo/lib/puppet/parser`  
`ln -s `gem env gemdir`/gems/hiera-puppet-0.3.0/lib/puppet/parser/functions`  

Create a simple Puppet manifest

`cat <<EOF > test.pp`  
`> $foo = hiera('foo')`  
`> notice("foo is $foo")`  
`> $kitties = hiera_hash('kitties')`  
`> notice("A hash of kitties! $kitties")`  
`> $evil_color = hiera('Evil', nil, 'pets/kitties')`  
`> $handsome_color = hiera('Handsome', nil 'pets/kitties')`  
`> notice("Evil is $evil_color and Handsome is $handsome_color")`  
`> EOF`  

Apply the manifest

`puppet apply --modulepath=/tmp/modules test.pp`

You should see similar output:

  notice: Scope(Class[main]): foo is bar
  notice: Scope(Class[main]): A hash of kitties!: EvilblackHandsomegray
  notice: Scope(Class[main]): Evil is black and Handsome is gray
  notice: Finished catalog run in 0.04 seconds

Contact
=======

* Author: Adam Kosmin c/o Reliant Security, Inc.
* Email: akosmin@reliantsecurity.com
* IRC (freenode): windowsrefund
* Myspace: yea right!

