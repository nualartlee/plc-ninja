FROM staticfloat/nginx-certbot

# To configure a site create a .conf file in the nginx folder.
# See certbot.conf regarding usage of ssl with certbot in the conf.
# All the .conf files found will be copied and enabled.
COPY *.conf /etc/nginx/conf.d/

# This is the default nginx configuration
COPY default/nginx.conf /etc/nginx/nginx.conf

