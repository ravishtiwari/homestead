#!/usr/bin/env bash

# Locale
LOCALE_LANGUAGE="en_US" # can be altered to your prefered locale
LOCALE_CODESET="en_US.UTF-8"

# Timezone
TIMEZONE="Europe/London" # can be altered to your specific timezone, see http://manpages.ubuntu.com/manpages/jaunty/man3/DateTime::TimeZone::Catalog.3pm.html

#----- end of configurable variables -----#

apt-get update
## sleep 2

# The provision check is intended to not run the full provision script when a box has already been provisioned.
echo "......................[vagrant provisioning]......................"
echo "Checking if the box was already provisioned..."

if [ -e "/home/vagrant/.provision_check" ]
then
  # Skipping provisioning if the box is already provisioned
  echo "......................[vagrant provisioning]......................"
  echo "The box is already provisioned..."
  exit
fi

echo "[vagrant provisioning] Updating mirrors in sources.list"

# prepend "mirror" entries to sources.list to let apt-get use the most performant mirror
sudo sed -i -e '1ideb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse\ndeb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse\n' /etc/apt/sources.list
sudo apt-get update

echo "......................[vagrant provisioning]......................"

echo "Installing Java..."
# sleep 2
sudo apt-get -y install curl
sudo apt-get -y install python-software-properties # adds add-apt-repository

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update

# automatic install of the Oracle JDK 7
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

sudo apt-get -y install oracle-java7-set-default


export JAVA_HOME="/usr/lib/jvm/java-7-oracle/jre"

echo "Checking Zip/Unzip"
command -v unzip >>/dev/null  2>&1 || { 
	echo "Zip command does not exists"
	echo "Installing zip/Unzip"
	echo "... ... "
	# sleep 2
	sudo apt-get -y install zip unzip
}
#sudo apt-get -y install unzip


echo "Checking Composer"
# sleep 3
command -v composer >>/dev/null  2>&1 || { 
	echo "Installing Composer"
	echo "... ... "
	echo "... ... ..."
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer
	ln -s /bin/composer /usr/local/bin/composer
	# sleep 2
}


echo "Checking Ant"
# sleep 1

echo "Installing apache ant"
# sleep 2
echo "... ... "
echo "... ... ..."

apt-get install ant -y

echo "Checking NodeJS"
command -v node >>/dev/null  2>&1 || {
	echo "Node.js does not exists"
	echo "Installing Node.js "
	# sleep 2
	echo "... ... "
	echo "... ... ..."
	# sleep 1
	apt-get install nodejs nodejs-dev -y
	# sleep 1
	echo "Installing npm"
	echo "... ... "
	echo "... ... ..."
	apt-get install npm -y
	echo "... ... "
	echo "... ... ..."
	# sleep 1
	npm install bower -g -y
	npm install gulp -y
	echo "... ... "
	echo "... ... ..."
	npm install -g grunt-cli grunt -y
	# sleep 2

}

echo "Checking MongoDB"
# sleep 5
command -v mongo >>/dev/null  2>&1 || { 
	echo "MongoDB does not exists"
	echo "Installing Mongo DB"
	echo "... ... "
	echo "... ... ..."
	apt-get install mongodb mongodb-server mongodb-clients php5-dev -y
	echo "restart mongodb "
	echo "... ... "
	# sleep 2
	echo "... ... ..."
	service mongodb restart
	echo "Installing php5-mongo"
	apt-get install php5-mongo -y
	echo "... ... "
	echo "... ... ..."
}
# sleep 10

echo "Checking Pear"
command -v pecl >>/dev/null  2>&1 || { 
	echo "PHP Pear does not exists"
	echo "Installing Pear"
	echo "... ... "
	# sleep 2
	apt-get install php-pear -y
}

echo "Installing php5-xdebug"
pecl install xdebug 
# sleep 2
echo "extension=xdebug.so" >/etc/php5/mods-available/xdeug.ini
ln -s /etc/php5/mods-available/xdeug.ini /etc/php5/fpm/conf.d/xdeug.ini

echo "Installing Mongo Driver"
echo "... ... "
# sleep 2
pecl install mongo 
echo "extension=mongo.so" >/etc/php5/mods-available/mongo.ini
ln -s /etc/php5/mods-available/mongo.ini /etc/php5/fpm/conf.d/mongo.ini
service ngnix restart
service php5-fpm restart

echo "Installing rabbitmq "
echo "... ... "
echo "... ... ..."
# sleep 5
echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list 

cd /tmp
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add rabbitmq-signing-key-public.asc
echo "... ... "
echo "... ... ..."
# sleep 1
echo "... ... ..."
echo "... ... "
apt-get update
apt-get install rabbitmq-server -y


#command -v unzip >>/dev/null  2>&1 || { 
#	echo "Zip command does not exists"
#	echo "Installing zip/Unzip"
#	echo "... ... "
#	# sleep 2
#	apt-get install zip unzip -y
#}

echo "Checking PHPMoadmin"
if [ ! -e "/home/vagrant/Code/phpmoadmin/index.php" ]
then
	echo "Installing PHP MoAdmin"
	cd /home/vagrant/Code
	mkdir phpmoadmin
	cd phpmoadmin
	wget http://www.phpmoadmin.com/file/phpmoadmin.zip
	unzip phpmoadmin.zip
	chmod 777 moadmin.php
	mv moadmin.php index.php
fi
echo "Checking PHP Adminer"
if [ ! -e "/home/vagrant/Code/phpadmin/index.php" ]
then
	echo "Installing PHP Mysql Admin : Adminer"
	cd /home/vagrant/Code
	mkdir phpadminer
	cd phpadminer
	wget http://softlayer-sng.dl.sourceforge.net/project/adminer/Adminer/Adminer%204.1.0/adminer-4.1.0.php	
	chmod 777 adminer-4.1.0.php
	mv adminer-4.1.0.php index.php
fi
#http://downloads.sourceforge.net/adminer/adminer-4.1.0.php


sudo dpkg --configure -a 
apt-get autoremove -y
# Create .provision_check for the script to check on during a next vargant up.
echo "......................[vagrant provisioning]......................"
echo "Creating .provision_check file..."
touch .provision_check
echo "......................[vagrant provisioning]......................"
echo " Development Boxes configured, now add following entries to your hosts file of host"
echo " 127.0.0.1  laravel.app"
echo " 127.0.0.1  moadmin.app"
echo " 127.0.0.1  phpadminer.app"
echo "..."
echo "..."
echo "Forwarded ports from host to guest are : "

printf "SSH: 2222 -> Forwards To 22 \nHTTP: 8000 -> Forwards To 80\n"
printf "MySQL: 33060 -> Forwards To 3306\nPostgres: 54320 -> Forwards To 5432\nMongo 27017 -> Forwards To 27018\n\n\n"

echo "Happy Coding :)"