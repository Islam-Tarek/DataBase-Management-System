function SelectRow(){
    ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    # use COLUMN COMMAND  to show the table formated

    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"
    
    # SELECT * FROM Persons5
    regex_all="^SELECT[[:space:]]*[*][[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    
    # SELECT PersonID, LastName, City FROM Persons
    regex_query="^SELECT[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*,?[[:space:]]*)+[[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    
    # To read array of input
    read  -p "Enter your select query: " select_query
    

   if [[ "$select_query" =~ $regex_all ]]; then
        table_name=`echo "$select_query" | awk '{print $NF;}'`
        column  "$table_name" -t -s ","
        return 0;


    elif [[ "$select_query" =~ $regex_query ]]; then

        # Table name
        table_name=$(echo "$select_query" | awk -F'FROM' '{print $2}' | xargs)
        
        # columns definations
        column_definitions=$(echo "$select_query" | awk -F'SELECT|FROM' '{print $2}' | xargs)
        
        echo "Table Name: $table_name"
        echo "Columns: $column_definitions"
        
        # will load the table references to the file to check the columns type
        source ./tb_col_types.sh


        # tables reference
        table_ref="tb_col_types.sh"

        # Check the table is exists or not    
        if ! grep -qw "$table_name" allTables; then 
            echo "The table $table_name does NOT exist."
            return 1
        fi

        # Ensure the table metadata exists in the loaded map
        if [[ -z "${!table_name[@]}" ]];
        then
            echo "No metadata founded for table $table_name .";
            return 1; 
        fi
    
        columns_names=`cat "$table_name" | head -n 1`
        echo "columnssssssssssssssss $columns_names"
        IFS=',' read -ra columns_array_tb <<< "$column_definitions"
        IFS=',' read -ra required_columns <<< "$columns_names"


        echo "Header Columns: ${columns_array_tb[@]}"
            echo "Query Columns: ${required_columns[@]}"
#            echo "Matched Indices: ${indices[@]}"


    indices=()
        
    for sel_col in "${columns_array_tb[@]}"; do
        sel_col=$(echo "$sel_col" | xargs) # Trim spaces
        found=0
        for i in "${!required_columns[@]}"; do

            if [[ "$sel_col" == "$(echo "${required_columns[i]}" | xargs)" ]]; then
                indices+=("$i")
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            echo "Column $sel_col does not exist in table $table_name."
            return 1
        fi
    done


    # Print header row for the selected columns
    output=""
    for index in "${indices[@]}"; do
        output+="${header_columns[index]},"
    done
    
    output=${output%,}  # Remove trailing comma
    echo "$output" > result.txt
    
    echo "---------,---------,---------" >> result.txt 


     # Print selected rows dynamically
    while IFS=',' read -ra row; do
        row_output=""
        for index in "${indices[@]}"; do
            row_output+="${row[index]},"
        done
        row_output=${row_output%,}  # Remove trailing comma
        echo "$row_output" >> result.txt
    done <<< "$data"

    # Use the `column` command to display the formatted output
    column -t -s ',' result.txt
    rm -f result.txt
    
    
   #elif [[  GET THE ROWS THAT HAVE THE VALUES IN WHERE CONDITION ]]; then
#####################################################################################
####################################################################
    else
        echo "Invalid query"
    fi


#     # Check values using regular expressions (?, *, _, ...)
#     # add LIMIT feature

 
    return 0
}

 SelectRow