#!/bin/bash

echo -e "\nScript de configuración automática de GNU/Linux\nDepartamento de Informática del IES Domingo Pérez Minik\n"

# check if is running as root
[ $(whoami) != root ] && echo "[ERROR] Please, run as root" && exit 1

IFS=$'\n'	

BASE_URL=https://raw.githubusercontent.com/iesdpm/informatica/master/config/linux
PACKAGES_FILE_URL=$BASE_URL/packages.txt
DEBS_FILE_URL=$BASE_URL/debs.txt
KEYS_FILE_URL=$BASE_URL/keys.txt
REPOS_FILE_URL=$BASE_URL/repos.txt
BINARIES_FILE_URL=$BASE_URL/binaries.txt

# download content from url
function downloadContent() {
	wget -qO- $1 | sed -r '/^\s*$/d'
}

# add apt key
function addAptKey() {
	echo "Add $1 APT key"
	url=$1
	wget -qO- $url | sudo apt-key add -
}

function addAptRepo() {
	echo "Add $1 repo to APT sources"
	repo=/etc/apt/sources.list.d/$1.list
	line=$2
	if [ ! -f $repo ]; then
		echo $line > $repo
	else
		echo "Repo $repo already exists"
	fi
}

# Installs DEB package from URL
function installDebFromUrl() {
	url=$1
	deb=/tmp/$(basename $url)
	echo -n "Installing $url package..."
	wget -qO $deb $url
	if dpkg -i $deb > /dev/null 2> /dev/null
	then
		echo "[OK]"
	else	
		echo "[ERROR]"
	fi
}

# Install from repos
function installFromRepos() {
	echo "Installing DEB packages from repos..."
	addRepos
	for package in $(downloadContent $PACKAGES_FILE_URL)
	do
		echo -n "Installing $package package..."
		if apt install -y $package > /dev/null 2> /dev/null
		then
			echo "[OK]"
		else	
			echo "[ERROR]"
		fi
	done
}

# Install DEB packages from URLs file
function installDebsFromUrls() {
	echo "Installing DEB packages from urls..."
	for url in $(downloadContent $DEBS_FILE_URL)
	do
		installDebFromUrl $url
	done
}

# Install software from binary installers
function installFromBinaries() {
	echo "Installing software from binaries/scripts..."
	for line in $(downloadContent $BINARIES_FILE_URL)
	do
		username=$(echo $line | cut -d, -f1)
		filename=$(echo $line | cut -d, -f2)
		url=$(echo $line | cut -d, -f3)
		binary=/tmp/$filename
		echo "Installing $filename ..."
		wget -qO $binary $url
		chmod +x $binary
		if [ "$username" == root ]; then
			$binary
		else
			/bin/su -c "$binary" - $username
		fi
	done
}


# add apt repository
function addRepos() {

	echo "Adding new APT repositories..."

	# add keys and repos
	for line in $(downloadContent $REPOS_FILE_URL)
	do
		name=$(echo $line | cut -d, -f1)
		keyUrl=$(echo $line | cut -d, -f2)
		repoUrl=$(echo $line | cut -d, -f3)
		if [ ! -z "$keyUrl" ]; then
			addAptKey "$keyUrl"
		fi
		addAptRepo "$name" "$repoUrl"
	done

	# update database packages list
	apt update

}

# packages installation
function installPackages() {
	echo "Installing packages..."
	installFromRepos
	installDebsFromUrls
	installFromBinaries
}


# create new user
function createUser() {
    echo "Creating user $1..."
	username=$1
	password=$2
	admin=$3
	if cat /etc/passwd | grep $username; then
		echo "User $username already exists"
	else
		useradd -m -s /bin/bash $username
		echo $username:$password | chpasswd
		if [ "$admin" = "true" ]; then
			adduser $username sudo
		fi
		echo "User $username created"
	fi
}

# schedule a task to shutdown computer everyday at 3pm
function scheduleShutdown() {
    echo "Schedule computer shutdown everyday at 3pm..."
	echo "0 15 * * * root /sbin/shutdown -h now" > /etc/cron.d/shutdown
}

# Packages installation
installPackages

# Create new users
echo "Creating users..."
createUser "alumno" "onmula" true

# Schedule a task to shutdown computer everyday at 3pm
scheduleShutdown

# Empty temporary directory
rm -fr /tmp/*
