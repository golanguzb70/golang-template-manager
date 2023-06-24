#!/bin/bash

folder_path="$TEMPLATE_PATH/templates"
if [ ! -d "$folder_path" ]; then
    # Create the folder
    mkdir -p "$folder_path"
fi

echo "Hello, good luck with your new project."
echo "Choose a template to start."
templates="go-gin-basicauth-postgres-monolithic go-gin-bearerauth-postgres-monolithic"

select template in $templates
do
    if [ "$template" == "go-gin-basicauth-postgres-monolithic" ]; then
        bash $TEMPLATE_PATH/'go-gin-basicauth-postgres-monolithic.sh'
        break
    elif [ "$template" == "go-gin-bearerauth-postgres-monolithic" ]; then
        bash $TEMPLATE_PATH/'go-gin-bearerauth-postgres-monolithic.sh'
        break
    fi
done