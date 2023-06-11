#!/bin/bash

current_path=$(pwd)
echo $current_path

cd $TEMPLATE_PATH

echo "Hello from go gin"

if [ -d "templates/go-gin-basicauth-postgres-monolithic-template" ]; then
        rm -rf "templates/go-gin-basicauth-postgres-monolithic-template"
fi

cd $TEMPLATE_PATH/templates
git clone https://github.com/golanguzb70/go-gin-basicauth-postgres-monolithic-template.git
cd go-gin-basicauth-postgres-monolithic-template
rm -rf .git

echo "Enter go module url"
read go_module
old_module="github.com/golanguzb70/go-gin-basicauth-postgres-monolithic-template"
# update template go module to new one
find  ./* -type f -exec sed -i "s|$old_module|$go_module|g" {} +

echo "Enter your first project crud name in lowercase letters: "
read crudname


rename_file() {
    local file_path=$1
    local crud=$2
    local dir_path=$(dirname "$file_path")
    local file_name=$(basename "$file_path")
    local new_name="${crud}"  # Remove the existing prefix, if any
    local new_path="$dir_path/$new_name"

    if [ "$file_name" == "template.go" ]; then
        mv "$file_path" "$new_path"
    fi
}

# Recursively process files within the folder
process_files() {
    local folder=$1
    local files=("$folder"/*)

    for file in "${files[@]}"; do
        if [ -d "$file" ]; then
            process_files "$file"  # Recursively process subfolders
        else
            rename_file "$file" "$crudname.go" # Rename individual files
        fi
    done
}

# Start processing files within the specified folder
process_files "$TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template"

title_crud=$(echo "$crudname" | sed -E 's/\b(\w)(\w*)/\u\1\2/g')

# Recursively process files within the folder
process_files_to_edit() {
    local folder=$1
    local files=("$folder"/*)

    for file in "${files[@]}"; do
        if [ -d "$file" ]; then
            if [[ "$file" != "./scripts" ]]; then
                process_files_to_edit "$file"  # Recursively process subfolders
            fi
        else
            find  ./* -type f -exec sed -i "s|template|$crudname|g" {} +
            find  ./* -type f -exec sed -i "s|Template|$title_crud|g" {} +
        fi
    done
}

process_files_to_edit "$TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template"

file_path="$TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/config/maker.env"

> "$file_path"
data1="export TEMPLATE_PATH='$TEMPLATE_PATH'"
data2="export GO_MOD_URL='$go_module'"
# Write the new data to the file
echo "$data1" > "$file_path"
echo "$data2" >> "$file_path"

# Copy the code to your current directory.
cp -r $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/* $current_path
rm -rf $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template
cd $current_path
go mod tidy
make swag_init