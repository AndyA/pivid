backend default {
  .host = "RASPBERRY PI'S ADDRESS";
  .port = "80";
}

sub vcl_recv {
  # Apple devices add a cookie which blows 
  # the cache. So we delete it.
  if (req.url ~ "\.(m3u8|ts)$") {
    remove req.http.cookie;
  }
}

sub vcl_fetch {
  if (req.url ~ "\.m3u8$") {
      set beresp.ttl = 2s;
  }
  if (req.url ~ "\.ts$") {
      set beresp.ttl = 1d;
  }
}
