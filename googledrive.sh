#!/bin/bash
#Script to automate the installation and mounting of Google Drive in a Debian based linux installation.
autofile="/usr/bin/gdfuse"
afname="gdfuse"

echo "Desired Mount point? Ensure this doesn't already exist."
read mount

sudo mkdir -p "$mount" > /dev/null

echo "Enter desired owner for mount point"
read user

#Check to see if the user exist, if it does set uid and gid for mounting
#2>&1 redirects STDERR to STDOUT if the user does not exist causing a value of 2 causing a false
#a false statement exiting the script
if id "$user" >/dev/null 2>&1; then  
        uid="$(id -u "$user")"
        gid="$(id -g "$user")"
	sudo chown "$user":"$user" "$mount"
	sudo chmod 755 "$mount"
  else
        echo "User does not exist"
        exit
fi


sudo add-apt-repository ppa:alessandro-strada/ppa -y > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install google-drive-ocamlfuse -y > /dev/null 2>&1

#checking the status of package installation
if [$? -ne 0]; then
	echo "failed to install necessary packages"
	exit  	
  else
	echo "Google Drive package was successfully installed"
fi

if [ -f "$autofile" ]; then
	echo "File found. Can't create automount script"
fi

sudo touch "$autofile"
echo -e "#!/bin/bash" | sudo tee -a "$autofile"
echo -e	"su "$user" -l -c "\"google-drive-ocamlfuse "$mount"""\" | sudo tee -a "$autofile"
echo -e "exit 0" | sudo tee -a "$autofile"
sudo chmod 755 "$autofile"

echo ""$afname"#default	"$mount"	fuse	uid="${uid}",gid="${gid}"	0	0" | sudo tee -a /etc/fstab

google-drive-ocamlfuse
wait ${!}

sudo mount "$mount"

