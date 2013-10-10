FROM polvi/node
MAINTAINER Brandon Philips <brandon@ifup.co>

ADD . /srv/scrup
ENTRYPOINT ["/usr/bin/node", "/srv/scrup/node_modules/coffee-script/bin/coffee", "/srv/scrup/server.coffee"]

EXPOSE 3000
