#!/bin/sh

if ! whoami &>/dev/null; then
  if [ -w /etc/passwd ]; then
    sed -i "s/^\(lighttpd:x:\)100:101/\1$(id -u):0/" /etc/passwd
  fi
fi

sed -i "s/\$PORT/$PORT/" /etc/lighttpd/lighttpd.conf
sed -i "s/\$TLSPORT/$TLSPORT/" /etc/lighttpd/lighttpd.conf

while read -r src dst; do
  cat <<-EOF >>/etc/lighttpd/lighttpd.conf
\$SERVER["socket"] == ":$PORT" {
  \$HTTP["host"] =~ "$src" {
    url.redirect = ( "^/(.*)" => "$dst" )
  }
}

\$SERVER["socket"] == ":$TLSPORT" {
  \$HTTP["host"] =~ "$src" {
    url.redirect = ( "^/(.*)" => "$dst" )
  }
}
EOF
done </etc/sites/sites.txt

cat <<EOF >/var/www/localhost/htdocs/index.html
<HTML>
<HEAD>
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
</HEAD>
<BODY>
$(hostname)
</BODY>
</HTML>
EOF

exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
