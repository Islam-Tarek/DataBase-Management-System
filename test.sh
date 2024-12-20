function CreateTable2(){

     # read -p "Enter Table Name: " table_name_create

    #  ## Need to write a validation cases to check 
    #     # the command executor is one of :
    #         # 1 - database owner  or root ?
    #         # 2 - this user in the owner group ? check the group privileges
    #         # 3 - others ? check the others privileges
    #     # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.
    
    
    # # Ask about columns number
    # echo "columns types is STRING -s or NUMBER -i"
    # echo "Enter each column name FOLLOWED by it's type seperated by a SPACE
    # -i for integers and -s for strings"
    

     ################################# i'm working here
    ## CREATE TABLE table_name (
    ##    col1_name type,
    ##    col2_name type 
    ## )

    ## CREATE TABLE Persons ( PersonID INT, LastName VARCHAR(14), FirstName VARCHAR(255), Address VARCHAR(14), City VARCHAR(14) )
        ### Need to enchance this query to accept VARCHAR type without count of letters

    read -p "Enter CREATE TABLE query: " query
    read -p "Write Column name AS a PRIMARY KEY for the Table: " primary_key

    # Regex for validating the CREATE TABLE syntax
    regex="^CREATE[[:space:]]+TABLE[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+(INT|VARCHAR\([[:space:]]*[0-9]{1,15}[[:space:]]*\))[[:space:]]*,?)+)\)[[:space:]]*?$"

    # Validate the query syntax
    if [[ $query =~ $regex ]]; then
        echo "Valid CREATE TABLE query."
    else
        echo "Invalid CREATE TABLE query syntax."
        return 1;
    fi

    # Extract table name
    table_name="${BASH_REMATCH[1]}"
    echo "tableeeeeeeeeeeeeee name  $table_name"
    # Extract column definitions
    column_definitions="${BASH_REMATCH[2]}"
    echo "column_definitionsssssssssssssssssss  $column_definitions"


    tb_ref="tb_col_types.sh"


     # 4- Check if there's a table with same name  ***
    if [[ -f "$table_name" ]]; then
        echo "There's a FILE have SAME name" && return 1;
    fi

    # Parse column definitions
    IFS=',' read -ra columns <<< "$column_definitions"
    
    # Validate column definitions
    flag=0
     for col in "${columns[@]}"; do
        # Remove extra whitespace
        col=$(echo "$col" | xargs)
        # Extract column name and type
        col_name=$(echo "$col" | awk '{print $1}')
        col_type=$(echo "$col" | awk '{print $2}')
        if [[ "$col_name" = "$primary_key" ]]; then
            flag=1
        fi
    done

    if [[ $flag -eq 0 ]]; then
        echo "Primary key not found in column definitions."
        return 1;
    fi


    # Create table file
    touch "$table_name" || { echo "FAILED to CREATE table"; return 1;}

     # push table name in (allTables) file
    echo "$table_name" >> "allTables"

    echo "$table_name:$primary_key" >> "$tb_ref"
    
    echo "declare -A $table_name=(" >> "$tb_ref"

    declare -A my_map

    for col in "${columns[@]}"; do
        # Remove extra whitespace
        col=$(echo "$col" | xargs)
        # Extract column name and type
        col_name=$(echo "$col" | awk '{print $1}')
        col_type=$(echo "$col" | awk '{print $2}')

        # Ensure col_name and col_type are valid before adding to the map
        if [[ -n "$col_name" && -n "$col_type" ]]; then
            my_map["$col_name"]="$col_type"
            echo "    [\"$col_name\"]=\"$col_type\"" >> "$tb_ref"
        fi
    done

    echo ")" >> "$tb_ref"
    echo " " >> "$tb_ref"
    echo
    echo "Map for table '$table_name' has been saved to $tb_ref."

    ## Need to create the table format using -----
    echo "-------------------------- $table_name" 
    echo "$column_definitions" >> "$table_name"
    echo ",,----------," >> "$table_name"
}


 CreateTable2


 primary_key=$(grep -w "$table_name" tb_col_types.sh | cut -d":" -f"2" | head -n 1)
    echo "PPPPPPrimary_KKKKKKeYYYY::::::::::::::::::   $primary_key"
    # Validate the column values

for i in "${!columns_array[@]}"; do
    # Remove extra spaces
    col_name=$(echo "${columns_array[i]}" | xargs)
    col_value=$(echo "${values_array[i]}" | xargs)
    echo "The table name isss:::::::::: $table_name"
    
    if [[ "$col_name" = "$primary_key" ]]; then
        echo "Primary key value is $col_value"
        filed_counter=0

        # Get the header line and find the index of the primary key column
        header=$(head -n 1 "$table_name")
        IFS=',' read -ra header_columns <<< "$header"
        for j in "${!header_columns[@]}"; do
            if [[ "${header_columns[j]}" = "$primary_key" ]]; then
                filed_counter=$((j + 1))
                break
            fi
        done

        # Check if the primary key value already exists
        check_primary_key_value=$(cut -d"," -f"$filed_counter" "$table_name" | grep -w "$col_value")
        if [[ "$check_primary_key_value" != "" ]]; then
            echo "Primary key value already exists."
            return 1
        fi
    fi



    # -- UPDATE Persons SET PersonID = 3 WHERE LastName = 'John2'  AND PersonID = '4'