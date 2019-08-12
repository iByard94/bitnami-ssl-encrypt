# bitnami-ssl-encrypt
A quick bash script that encrypts WordPress Bitnami builds on Apache servers.
The script takes in user-input for the domain name linked to the server. (ie: mywebsite.com)
The domain is then confirmed to ensure proper spelling
The script then procedes to install certbot-auto by Let's Encrypt
It makes the necessary changes to the htdocs, the wp-config, and it sets up a crontab to reencrypt the site every month.


How to install on an Ubuntu server
 1. sudo nano /INSTALL_SSL
 2. Paste the contents of the INSTALL_SSL file
 3. Save (ctr+x > y > enter)
 4. sudo chmod +x /INSTALL_SSL
 5. sudo /./INSTALL_SSL
