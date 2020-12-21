#!/bin/sh

sed -i "s/\$PORT/$PORT/" /etc/lighttpd/lighttpd.conf

while read -r src dst; do
  cat <<-EOF >>/etc/lighttpd/lighttpd.conf
\$SERVER["socket"] == ":$PORT" {
  \$HTTP["host"] =~ "$src" {
    url.redirect = ( "^/(.*)" => "$dst" )
    # url.redirect = ( "^/(.*)" => "https://%1" )
  }
}

EOF
done </etc/sites.txt
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
