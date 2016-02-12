#!/usr/bin/env bash
#---------------------------------------------------------------------
# install.sh
#
# ISPConfig 3 system installer
#
# Script: install.sh
# Version: 1.0.15
# Author: Matteo Temporini <temporini.matteo@gmail.com>
# Description: This script will install all the packages needed to install
# ISPConfig 3 on your server.
#
#
#---------------------------------------------------------------------

#Those lines are for logging porpuses
exec > >(tee -i /var/log/ispconfig_setup.log)
exec 2>&1

#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
CFG_HOSTNAME_FQDN=`hostname -f`;
WT_BACKTITLE="ISPConfig 3 System Installer from Temporini Matteo"

# Bash Colour
red='\033[0;31m'
green='\033[0;32m'
NC='\033[0m' # No Color


#Saving current directory
PWD=$(pwd);

#---------------------------------------------------------------------
# Load needed functions
#---------------------------------------------------------------------

source $PWD/functions/check_linux.sh
echo "Checking your system, please wait..."
CheckLinux
#---------------------------------------------------------------------
# Load needed Modules
#---------------------------------------------------------------------

source $PWD/distros/$DISTRO/preinstallcheck.sh
source $PWD/distros/$DISTRO/askquestions.sh
source $PWD/distros/$DISTRO/askquestions_multiserver.sh
source $PWD/distros/$DISTRO/install_basics.sh
source $PWD/distros/$DISTRO/install_mysql.sh
source $PWD/distros/$DISTRO/install_mta.sh
source $PWD/distros/$DISTRO/install_webserver.sh
source $PWD/distros/$DISTRO/install_ftp.sh
source $PWD/distros/$DISTRO/install_quota.sh
source $PWD/distros/$DISTRO/install_bind.sh
source $PWD/distros/$DISTRO/install_webstats.sh
source $PWD/distros/$DISTRO/install_jailkit.sh
source $PWD/distros/$DISTRO/install_fail2ban.sh
source $PWD/distros/$DISTRO/install_ispconfig.sh
source $PWD/distros/$DISTRO/install_fix.sh

#---------------------------------------------------------------------
# Main program [ main() ]
#    Run the installer
#---------------------------------------------------------------------
clear
echo "Welcome to ISPConfig Setup Script v.1.0.15"
echo "This software is developed by Temporini Matteo"
echo "with the support of the community."
echo "You can visit my website at the followings URLS"
echo "http://www.servisys.it http://www.temporini.net"
echo "and contact me with the following information"
echo "contact email/hangout: temporini.matteo@gmail.com"
echo "skype: matteo.temporini"
echo "========================================="
echo "ISPConfig 3 System installer"
echo "========================================="
echo
echo "This script will do a nearly unattended intallation of"
echo "all software needed to run ISPConfig 3."
echo "When this script starts running, it'll keep going all the way"
echo "So before you continue, please make sure the following checklist is ok:"
echo
echo "- This is a clean standard clean installation for supported systems";
echo "- Internet connection is working properly";
echo
echo
if [ -n "$PRETTY_NAME" ]; then
	echo -e "The detected Linux Distribution is: " $PRETTY_NAME
else
	echo -e "The detected Linux Distribution is: " $ID-$VERSION_ID
fi
echo
if [ -n "$DISTRO" ]; then
	read -p "Is this correct? (y/n)" -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
		exit 1
	fi
else
	echo -e "Sorry but your System is not supported by this script, if you want your system supported "
	echo -e "open an issue on GitHub: https://github.com/servisys/ispconfig_setup"
	exit 1
fi

if [ $DISTRO == "debian8" ]; then
         while [ "x$CFG_MULTISERVER" == "x" ]
          do
                CFG_MULTISERVER=$(whiptail --title "MULTISERVER SETUP" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Would you like to install ISPConfig in a MultiServer Setup?" 10 50 2 "no" "(default)" ON "yes" "" OFF 3>&1 1>&2 2>&3)
          done
fi

if [ -f /etc/debian_version ]; then
  PreInstallCheck
  if [ $CFG_MULTISERVER == "no" ]; then
	AskQuestions
  else
	AskQuestionsMultiserver
  fi
  InstallBasics 
  InstallSQLServer 
  if [ $CFG_SETUP_WEB == "y" ] || [ $CFG_MULTISERVER == "no" ]; then
    InstallWebServer
    InstallFTP 
    if [ $CFG_QUOTA == "y" ]; then
    InstallQuota 
    fi
    if [ $CFG_JKIT == "y" ]; then
    InstallJailkit 
    fi
    InstallWebmail 
  else
	InstallBasePhp    #to remove in feature release
  fi  
  if [ $CFG_SETUP_MAIL == "y" ] || [ $CFG_MULTISERVER == "no" ]; then
    InstallPostfix 
    InstallMTA 
    InstallAntiVirus 
  fi  
  if [ $CFG_SETUP_NS == "y" ] || [ $CFG_MULTISERVER == "no" ]; then
    InstallBind 
  fi  
  InstallWebStats   
  InstallFail2ban 
  InstallISPConfig
  InstallFix
  echo -e "${green}Well done ISPConfig installed and configured correctly :D ${NC}"
  echo "Now you can connect to your ISPConfig installation at https://$CFG_HOSTNAME_FQDN:8080 or https://IP_ADDRESS:8080"
  echo "You can visit my GitHub profile at https://github.com/servisys/ispconfig_setup/"
  if [ $CFG_WEBMAIL == "roundcube" ]; then
	echo -e "${red}You had to edit user/pass /var/lib/roundcube/plugins/ispconfig3_account/config/config.inc.php of roudcube user, as the one you inserted in ISPconfig ${NC}"
  fi
  if [ $CFG_WEBSERVER == "nginx" ]; then
  	echo "Phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin";
	echo "Webmail is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/webmail or http://IP_ADDRESS:8081/webmail";
  fi
else 
	if [ -f /etc/centos-release ]; then
		echo "Attention pls, this is the very first version of the script for Centos 7"
		echo "Pls use only for test pourpose for now."
		echo -e "${red}Not yet implemented: courier, nginx support${NC}"
		echo -e "${green}Yet implemented: apache, mysql, bind, postfix, dovecot, roudcube webmail support${NC}"
		echo "Help us to test and implement, press ENTER if you understand what i'm talinkg about..."
		read DUMMY
		PreInstallCheck
		AskQuestions 
		InstallBasics 
		InstallSQLServer 
		InstallMTA 
		InstallWebServer
		InstallFTP 
		#if [ $CFG_QUOTA == "y" ]; then
		#		InstallQuota 
		#fi
		InstallBind 
        InstallWebStats 
	    if [ $CFG_JKIT == "y" ]; then
			InstallJailkit 
	    fi
		InstallFail2ban 
		InstallISPConfig
		#InstallFix
		echo -e "${green}Well done ISPConfig installed and configured correctly :D ${NC}"
		echo "Now you can connect to your ISPConfig installation at https://$CFG_HOSTNAME_FQDN:8080 or https://IP_ADDRESS:8080"
		echo "You can visit my GitHub profile at https://github.com/servisys/ispconfig_setup/"
		echo -e "${red}If you setup Roundcube webmail go to http://$CFG_HOSTNAME_FQDN/roundcubemail/installer and configure db connection${NC}"
		echo -e "${red}After that disable access to installer in /etc/httpd/conf.d/roundcubemail.conf${NC}"
	else
		echo "${red}Unsupported linux distribution.${NC}"
	fi
fi

exit 0

