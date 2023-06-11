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


old_module="github.com/golanguzb70/go-gin-basicauth-postgres-monolithic-template"
# update template go module to new one
find  ./* -type f -exec sed -i "s|$old_module|$GO_MOD_URL|g" {} +

echo "Enter crud name in lowercase letters: "
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

update_word() {
    local file_path=$1

    sed -i "s/template/$crudname/g" "$file_path"
    sed -i "s/Template/$title_crud/g" "$file_path"
}

# Recursively process files within the folder
process_files_to_edit() {
    local folder=$1
    local files=("$folder"/*)

    for file in "${files[@]}"; do
        if [ -d "$file" ]; then
            if [[ "$file" != "$TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/scripts" ]]; then
                echo $file
                process_files_to_edit "$file"  # Recursively process subfolders
            fi
        else
            # find  ./* -type f -exec sed -i "s|template|$crudname|g" {} +
            # find  ./* -type f -exec sed -i "s|Template|$title_crud|g" {} +
            update_word "$file"  
        fi
    done
}

process_files_to_edit "$TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template"

# Copy handler level.
cp -r $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/api/handlers/v1/$crudname.go $current_path/api/handlers/v1/
# Copy database Level.
cp -r $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/storage/postgres/$crudname.go $current_path/storage/postgres/

# Copy models.
cp -r $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template/models/$crudname.go $current_path/models


# add new endpoints to router.go file
cd $current_path
file_path="api/router.go"

# Specify the word after which you want to add the lines
target_word="// Don't delete this line, it is used to modify the file automatically"

# Specify the lines you want to add
lines_to_add=(
"	${crudname} := api.Group(\"/${crudname}\")"
"	${crudname}.POST(\"\", h.${title_crud}Create)"
"	${crudname}.GET(\"/:id\", h.${title_crud}Get)"
"	${crudname}.GET(\"/list\", h.${title_crud}Find)"
"	${crudname}.PUT(\"\", h.${title_crud}Update)"
"   ${crudname}.DELETE(\":id\", h.${title_crud}Delete)"
""
)

# Temporary file path for storing modified content
temp_file="${file_path}.temp"

# Flag to track whether the word was found
word_found=false

# Read the file line by line
while IFS= read -r line; do
    if [[ $line == *"$target_word"* ]]; then
        word_found=true
        
        # Add the lines after the target word
        for additional_line in "${lines_to_add[@]}"; do
            echo "$additional_line" >> "$temp_file"
        done
    fi
    echo "$line" >> "$temp_file"
    
    # Check if the target word is found in the line
done < "$file_path"

# Replace the original file with the modified content
if [ "$word_found" = true ]; then
    mv "$temp_file" "$file_path"
    echo "Lines added after '$target_word' in '$file_path'."
else
    rm "$temp_file"
    echo "Word '$target_word' not found in '$file_path'. No lines added."
fi

# Add new crud to handler interface.
file_path_handler_interface="api/handlers/v1/handler.go"

# Specify the word after which you want to add the lines
target_word="// Don't delete this line, it is used to modify the file automatically"

# Specify the lines you want to add
lines_to_add_handler_interface=(
"	${title_crud}Create(c *gin.Context)"
"	${title_crud}Get(c *gin.Context)"
"	${title_crud}Find(c *gin.Context)"
"	${title_crud}Update(c *gin.Context)"
"	${title_crud}Delete(c *gin.Context)"
)

# Temporary file path for storing modified content
temp_file_handler_interface="${file_path_handler_interface}.temp"

# Flag to track whether the word was found
word_found=false

# Read the file line by line
while IFS= read -r line; do
    if [[ $line == *"$target_word"* ]]; then
        word_found=true
        
        # Add the lines after the target word
        for additional_line in "${lines_to_add_handler_interface[@]}"; do
            echo "$additional_line" >> "$temp_file_handler_interface"
        done
    fi
    echo "$line" >> "$temp_file_handler_interface"
    
    # Check if the target word is found in the line
done < "$file_path_handler_interface"

# Replace the original file with the modified content
if [ "$word_found" = true ]; then
    mv "$temp_file_handler_interface" "$file_path_handler_interface"
    echo "Lines added after '$target_word' in '$file_path_handler_interface'."
else
    rm "$temp_file_handler_interface"
    echo "Word '$target_word' not found in '$file_path_handler_interface'. No lines added."
fi

# Add new methods to postgres repo Interface
file_path_postgres_repo="storage/postgres/repo.go"

# Specify the word after which you want to add the lines
target_word="// Don't delete this line, it is used to modify the file automatically"

# Specify the lines you want to add
lines_to_add_postgres_repo=(
"	${title_crud}Create(ctx context.Context, req *models.${title_crud}CreateReq) (*models.${title_crud}Response, error)"
"	${title_crud}Get(ctx context.Context, req *models.${title_crud}GetReq) (*models.${title_crud}Response, error)"
"	${title_crud}Find(ctx context.Context, req *models.${title_crud}FindReq) (*models.${title_crud}FindResponse, error)"
"	${title_crud}Update(ctx context.Context, req *models.${title_crud}UpdateReq) (*models.${title_crud}Response, error)"
"	${title_crud}Delete(ctx context.Context, req *models.${title_crud}DeleteReq) error"
)

# Temporary file path for storing modified content
temp_file_postgres_repo="${file_path_postgres_repo}.temp"

# Flag to track whether the word was found
word_found=false

# Read the file line by line
while IFS= read -r line; do
    if [[ $line == *"$target_word"* ]]; then
        word_found=true
        
        # Add the lines after the target word
        for additional_line in "${lines_to_add_postgres_repo[@]}"; do
            echo "$additional_line" >> "$temp_file_postgres_repo"
        done
    fi
    echo "$line" >> "$temp_file_postgres_repo"
    
    # Check if the target word is found in the line
done < "$file_path_postgres_repo"

# Replace the original file with the modified content
if [ "$word_found" = true ]; then
    mv "$temp_file_postgres_repo" "$file_path_postgres_repo"
    echo "Lines added after '$target_word' in '$file_path_postgres_repo'."
else
    rm "$temp_file_postgres_repo"
    echo "Word '$target_word' not found in '$file_path_postgres_repo'. No lines added."
fi

rm -rf $TEMPLATE_PATH/templates/go-gin-basicauth-postgres-monolithic-template