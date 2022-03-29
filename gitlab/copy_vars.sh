TEMP_FILE=./temp_file
args=("$@")

if [[ $# -eq 0 ]] ; then
   echo 'error: No arguments provided.\n
   Usage: ./update_variables.sh <SOURCE_PROJECT_ID> <DESTINATION_PROJECT_ID>'
    exit 1
fi


get_s_variable_keys () {
    gitlab -o json project-variable list --project-id ${args[0]} > $TEMP_FILE
    KEYS=$(jq -r ".[] | .key" ./temp_file)
}

set_d_variable_values () {
    for each_key in $KEYS; do
        echo "Setting value for key $each_key...."
        VALUE=`jq -r --arg e "${each_key}" '.[] | select(.key == $e) | .value' $TEMP_FILE`
        TYPE=`jq -r --arg e "${each_key}" '.[] | select(.key == $e) | .variable_type' $TEMP_FILE`
        gitlab -o json project-variable create --project-id "${args[1]}" --key $each_key --value "$VALUE" --variable-type "$TYPE"
    done
}

get_s_variable_keys
set_d_variable_values

rm $TEMP_FILE
