# golang-template-manager
This is a tool that makes it easy to build fast, reliable and easy to understand template manager that manages golang templates that are written by experienced software engineers.

# How to install?

1. Clon using following commands
```
cd 
git clone https://github.com/golanguzb70/golang-template-manager
sudo chmod 770 ./golang-template-manager/*
```
2. Set alias to run bash commands easily.
Add the following lines of script to your .bashrc, .zshrc or .profile depending on your OS and your choice.
```
export TEMPLATE_PATH="~/go/golang-template-manager"
alias newtemplate="~/golang-template-manager/main.sh"
```
3. To submit the configuration, run the following command
```
# put your choice instead of .zshrc
source .zshrc
```

# Create new project
To create a new project run the command below and follow all the instructions that are given after that command.
```
newtemplate
```
