# moonshine_dnsmasq

This is a Moonshine plugin to manage dnsmasq, which is a handy way to deal with flakey DNS servers and increase performance when doing lookups.

## Requirements

* An app already configured with   [Moonshine](http://github.com/railsmachine/moonshine).

## Configuration

Add this to your manifest:

<pre><code>include Moonshine::Dnsmasq</code></pre>

There's only one configuration option currently, so here's what your dnsmasq section in moonshine.yml should look like:

<pre><code>:dnsmasq:
  :cache_size: 256</code></pre>
  
You should also add this line to your application manifest:

<pre><code>recipe :dnsmasq</code></pre>

You'll also need to change your resolv.conf and add the following line to the top, before the other nameservers:

<pre><code>nameserver 127.0.0.1</code></pre>

And that's it!