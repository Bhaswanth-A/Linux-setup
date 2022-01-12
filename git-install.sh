#!/bin/bash

## Update packages and Upgrade system
sudo apt-get update -y

## Git ##
echo '###Installing Git..'
sudo apt-get install git -y

# Git Configuration
echo '###Congigure Git..'

echo "Enter the Global Username for Git:";
read GITUSER;
git config --global user.name "${GITUSER}"

echo "Enter the Global Email for Git:";
read GITEMAIL;
git config --global user.email "${GITEMAIL}"

echo 'Git has been configured!'
git config --list

sudo apt update
sudo snap install code --classic
