########################################################################################
########################################################################################
########################## AUTO SSL ENCRYPTER WITH CRONTAB #############################
########################################################################################
########################################################################################
# How to install on an Ubuntu server
# 1. sudo nano /INSTALL_SSL
# 2. Paste the contents of this document
# 3. Save (ctr+x then y)
# 4. sudo chmod +x /INSTALL_SSL
# 5. sudo /./INSTALL_SSL


read -p 'Website (ie: website.com): ' MY_DOMAIN_NAME
read -p 'Confirm Website: ' CONFIRM
if [ $MY_DOMAIN_NAME = $CONFIRM ]
then
	echo "They matched."
	#installs certbot
	wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto
	./certbot-auto certonly --webroot -w /opt/bitnami/apps/wordpress/htdocs/ -d $MY_DOMAIN_NAME -d www.$MY_DOMAIN_NAME
	wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto
	sudo mv certbot-auto /etc/letsencrypt/
	#Adds 3 new lines of code describing the domain name
	sudo sed -i 's!<VirtualHost _default_:80>!<VirtualHost _default_:80> \n #modified by BOM \n ServerName www.'$MY_DOMAIN_NAME' \n ServerAlias '$MY_DOMAIN_NAME' \n Redirect / https://www.'$MY_DOMAIN_NAME' \n!' /opt/bitnami/apache2/conf/bitnami/bitnami.conf
	#Comments out the defauly SSL cert key files and inserts the new ones.
	sudo sed -i 's!SSLCertificateFile "/opt/bitnami/apache2/conf/server.crt"!#commented out by BOM\n#SSLCertificateFile "/opt/bitnami/apache2/conf/server.crt"!' /opt/bitnami/apache2/conf/bitnami/bitnami.conf
	sudo sed -i 's!SSLCertificateKeyFile "/opt/bitnami/apache2/conf/server.key"!#commented out by BOM\n#SSLCertificateKeyFile "/opt/bitnami/apache2/conf/server.key" \n SSLCertificateFile "/etc/letsencrypt/live/'$MY_DOMAIN_NAME'/cert.pem" \n SSLCertificateKeyFile "/etc/letsencrypt/live/'$MY_DOMAIN_NAME'/privkey.pem" \n SSLCertificateChainFile "/etc/letsencrypt/live/'$MY_DOMAIN_NAME'/chain.pem"!' /opt/bitnami/apache2/conf/bitnami/bitnami.conf
	#Changes the default URL of the site to HTTPS in the wp-config.php document for both the WP_HOME & WP_SITEURL
	sudo sed -i 's!define('\''WP_HOME'\'', '\''http://'\'' . $_SERVER\['\''HTTP_HOST'\''\] . '\''/'\'');!define('\''WP_HOME'\'','\''https://'$MY_DOMAIN_NAME''\'');!' /opt/bitnami/apps/wordpress/htdocs/wp-config.php
	sudo sed -i 's!define('\''WP_SITEURL'\'', '\''http://'\'' . $_SERVER\['\''HTTP_HOST'\''\] . '\''/'\'');!define('\''WP_SITEURL'\'','\''https://'$MY_DOMAIN_NAME''\'');!' /opt/bitnami/apps/wordpress/htdocs/wp-config.php
	#SETS UP THE CRONTAB
	#CREATES THE FILE NEWNEW_SSL_CERT TO BE RUN BY THE CRONTAB
	printf > /RENEW_SSL_CERT "if test -f "\""/certbot-auto"\""; then\n./certbot-auto certonly --webroot -w /opt/bitnami/apps/wordpress/htdocs/ -d "$MY_DOMAIN_NAME" -d www."$MY_DOMAIN_NAME"\nsudo /opt/bitnami/ctlscript.sh restart apache\nelse\nwget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto\n./certbot-auto certonly --webroot -w /opt/bitnami/apps/wordpress/htdocs/ -d "$MY_DOMAIN_NAME" -d www."$MY_DOMAIN_NAME"\nsudo /opt/bitnami/ctlscript.sh restart apache\nfi"
	#MODIFY THE CRONTAB TO RUN EVERY MONTH ON THE FIRST:    * * * 1 * /RENEW_SSL_CERT
	sudo chmod +x /RENEW_SSL_CERT
	cat <(crontab -l) <(echo "* * * 1 * sudo /./RENEW_SSL_CERT") | crontab -
	echo "All done! We just need to restart..."
	sudo /opt/bitnami/ctlscript.sh restart apache
else
	echo "Try again."
fi
