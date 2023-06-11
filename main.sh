#!/bin/bash

echo "Hello, good luck with your new project."
echo "Choose a template to start."
echo '1. Golang, postgres, gin, swagger, basic auth'


read template;

if [ $template -eq 1 ]; then
    $TEMPLATE_PATH/'go-gin-basicauth-postgres-monolithic.sh'
fi