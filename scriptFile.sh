#!/bin/env bash


### Need switch..case to choose the operation
# Function to display the main menu
function MainMenu(){
    echo "  Main Menu"
    echo "----------------"

    # Validation cases to check user privileges can be added here

    echo "Write a number from the Menu: "
    echo "1)  Create Database"
    echo "2)  List Databases"
    echo "3)  Connect to a Database"
    echo "4)  Drop a Database"
    echo "
    -------------------------------
    "
}

# Function to display the connect database menu
function ListDatabases(){
    
    echo "All Databases : "

    for database_name in `ls`;
    do
        if [[ -d $database_name ]]; then
            echo "$database_name"
        fi
    done

    return 0
}

function ConnectToDatabases(){

    read -p "Enter the Database name that you want CONNECT to it: " db_name_connect

    if [[ -d "$db_name_connect" ]]; then
        cd "$db_name_connect"
        echo "Connected to database: $db_name_connect SUCCESSFULLY"
    else
         echo "Database $db_name_connect NOT found"
    fi

    # for database_name in `ls`;
    # do
    #     if [[ -d "$database_name" && "$database_name" = "$db_name_connect" ]]; then
    #         ## Need to write a validation cases to check 
    #             # the command executor is one of :
    #                 # 1 - database owner  or root ?
    #                 # 2 - this user in the owner group ? check the group privileges
    #                 # 3 - others ? check the others privileges 

    #         cd "$database_name" || { echo "Failed to change directory"; return 1; }
    #         echo "Connected to database: $database_name SUCCESSFULLY"
    #         return 0;
    #     fi
    # done 

    # echo "Directory not found or not accessible."
}


function DropDatabase(){

    read -p "Enter the Database name that you want to DROP it: " db_name_drop

    for database_name in `ls`;
    do  
        if [[ -d "$database_name" && "$database_name" = "$db_name_drop" ]]; then
            ## Need to write a validation cases to check 
                # the command executor is one of :
                    # 1 - database owner  or root ?
                    # 2 - this user in the owner group ? check the group privileges
                    # 3 - others ? check the others privileges

            rm -rf "$db_name_drop" || { echo "Faliled to DROP this database"; return 1; }
            
            echo "$db_name_drop database is DROPED SUCCESSFULLY"
            return 0;
        fi
    done

    echo "Database $db_name_drop NOT found or NOT accessible"
    return 1;
}



function CreateDatabase(){

    read -p "Enter the Database name that you want to CREATE it: " db_name_create

     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
    
    if [[ -d "$db_name_create" ]]; then
        echo "There's a directory have SAME name" && return 1;
    fi

    mkdir "$db_name_create" || { echo "Faliled to CREATE this database"; return 1; }

    touch "$db_name_create"/allTables || { echo "Faliled to CREATE allTables file"; return 1; }
    
    touch "$db_name_create"/tb_col_types.sh || { echo "Faliled to CREATE tb_col_types file"; return 1; }

    echo "$db_name_create database is CREATED SUCCESSFULLY" && return 0;  
    
    echo "You are NOT accessible to CREATE database"
    return 1;
}   

### -----------------------------------------------------------------------------------

function ConnectDatabaseMenu(){
    echo "  Connect to Database Menu"
    echo "----------------"

    # Validation cases to check user privileges can be added here

    echo "Write a number from the Menu: "
    echo "1)  Create Table"
    echo "2)  List Tables"
    echo "3)  Drop Table"
    echo "4)  Insert Row into Table"
    echo "5)  Select Row from Table"
    echo "6)  Delete Row from Table"
    echo "7)  Update Row in Table"
    echo "
    -------------------------------
    "
}

function CreateTable(){

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
    echo "$column_definitions" >> "./$table_name"
    echo ",,----------," >> "./$table_name"
}


#  CreateTable


function ListTables(){

     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges

    cat ./allTables || { echo "allTables file NOT exist"; return 1;}

    return 0;
}

#  ListTables

function DropTable(){

    ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges

    read -p "Enter the Table name that you want DROP it: " table_name_drop

    # Delete lines containing the map
    sed -i "/^declare -A $table_name_drop=/,/^)/d" tb_col_types.sh || { echo "FAILED to DELETE table map"; return 1;}

    # Delete the table name at (allTables)
        ## \< matches the start of the word and \> to matches the end of the word
        ## because I need to match the exact name of the table to prevent false deletion
    sed -i "/\<$table_name_drop\>/d" allTables || { echo "FAILED to DELETE table name"; return 1;}

    # Remove whole the table
    rm -f "$table_name_drop" || { echo "FAILED to DROP the table"; return 1;}

    delete_operation_stat=`echo $?`

    if [[ $delete_operation_stat = "0" ]]; then
        echo "$table_name_drop is DROPED SUCCESSFULLY"; return 0;
    else
        echo "FAILED to DROP $table_name_drop table"; return 1;
    fi

}   

# DropTable

function InsertRow(){
    ## Regex for validating the INSERT query syntax - improved version
    regex1="^INSERT[[:space:]]+INTO[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*,?[[:space:]]*)+)\)[[:space:]]*VALUES[[:space:]]*\((([[:space:]]*'[^']*'|[0-9]+)[[:space:]]*,?[[:space:]]*)*\)[[:space:]]*$"

    # Read insert query
    read -p "Enter your INSERT query: " query
    
    if [[ ! $query =~ $regex1 ]]; then
        echo "Invalid INSERT ROW query syntax"
        # Debug output to help identify the issue
        echo "Debug - Query received: $query"
        return 1
    fi
    
    # Extract query components with improved whitespace handling
    table_name=$(echo "$query" | awk -F'[()]' '{print $1}' | sed -E 's/^INSERT[[:space:]]+INTO[[:space:]]+//g' | xargs)
    column_definitions=$(echo "$query" | awk -F'[()]' '{print $2}' | xargs)
    values=$(echo "$query" | awk -F'VALUES[[:space:]]*[(]' '{print $2}' | sed -E 's/[)]$//g' | xargs)

    # Debug output
    echo "Debug - Table: $table_name"
    echo "Debug - Columns: $column_definitions"
    echo "Debug - Values: $values"

    # Rest of your existing function remains the same
    # Check if table exists
    if ! grep -qw "$table_name" allTables; then 
        echo "The table $table_name does NOT exist."
        return 1
    fi

    # Get primary key from tb_col_types.sh
    primary_key=""
    while IFS=':' read -r tname pkey; do
        if [[ "$tname" == "$table_name" ]]; then
            primary_key="$pkey"
            break
        fi
    done < <(grep -v "^declare" tb_col_types.sh)

    if [[ -z "$primary_key" ]]; then
        echo "Could not find primary key for table $table_name"
        return 1
    fi

    # Convert columns and values to arrays
    IFS=',' read -ra columns_array <<< "$column_definitions"
    IFS=',' read -ra values_array <<< "$values"

    # Validate column count matches value count
    if [[ ${#columns_array[@]} -ne ${#values_array[@]} ]]; then
        echo "Column count and values do not match."
        return 1
    fi

    # Find primary key value and position
    pk_value=""
    pk_position=-1
    for i in "${!columns_array[@]}"; do
        col_name=$(echo "${columns_array[$i]}" | xargs)
        if [[ "$col_name" == "$primary_key" ]]; then
            pk_value=$(echo "${values_array[$i]}" | tr -d "'" | xargs)
            pk_position=$((i + 1))
            break
        fi
    done

    if [[ -z "$pk_value" ]]; then
        echo "Primary key column not found in INSERT statement"
        return 1
    fi

    # Check if primary key value already exists
    while IFS=',' read -ra row; do
        if [[ -n "${row[$((pk_position-1))]}" && "${row[$((pk_position-1))]}" == "$pk_value" ]]; then
            echo "Primary key value $pk_value already exists in table."
            return 1
        fi
    done < <(tail -n +3 "$table_name")

    # If we get here, the primary key is unique, so we can insert
    formatted_values=$(echo "$values" | sed "s/, /,/g")
    echo "$formatted_values" >> "$table_name" && 
    echo "New Row added SUCCESSFULLY to table $table_name" && 
    return 0

    echo "FAILED to INSERT ROW IN $table_name table"
    return 1
}
# InsertRow;


function SelectRow(){
    ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    # use COLUMN COMMAND  to show the table formated

  #   SELECT * FROM Persons;
    regex_all="^SELECT[[:space:]]*[*][[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    # SELECT PersonID, LastName, FirstName FROM Persons
    regex_some_col="^SELECT[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*,?[[:space:]]*)+[[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    # SELECT PersonID, LastName, FirstName, Address FROM Persons WHERE City = 'Lala land2'
    regex="^SELECT[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*,[[:space:]]*)*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+WHERE[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*'[^']*'[[:space:]]*$"
    # To read array of input
    read -p "Enter your select query: " select_query
    # Checking for different query formats
    if [[ "$select_query" =~ $regex_all ]]; then
        echo "Matched regex_all"
        table_name=$(echo "$select_query" | awk '{print $NF;}')
        column "$table_name" -t -s ","
        return 0
    elif [[ "$select_query" =~ $regex_some_col ]]; then
        echo "Matched regex_some_col"
        table_name=$(echo "$select_query" | awk -F'FROM' '{print $2}' | xargs)
        echo "Table Name: $table_name"
        columns=$(echo "$select_query" | awk -F'SELECT' '{print $2}' | awk -F'FROM' '{print $1}' | xargs)
        echo "Columns: $columns"

        # Check if file exists
        if [[ -z "$table_name" || -z "$columns" ]]; then
            echo "Invalid query format."
            return 1
        fi
        # Check if file exists
        if [[ ! -f $table_name ]]; then
            echo "Table $table_name does not exist."
            return 1
        fi
        # Read the header (column names) and data from the file
header=$(head -1 "$table_name")
        echo "Header: $header"
data=$(tail -n +3 "$table_name")  # Skip header and separator line
        echo "Data: $data"
        # Convert header to an array
IFS=',' read -a header_columns <<< "$header"
        echo "Header Columns: ${header_columns[@]}"
        # Trim whitespace from header columns
for i in "${!header_columns[@]}"; do
    header_columns[$i]=$(echo "${header_columns[$i]}" | xargs)
done
        # Convert selected columns to an array
        IFS=',' read -ra selected_columns <<< "$columns"
        echo "Selected Columns: ${selected_columns[@]}"
        
        # Find indices of the selected columns in the header
        # Find indices of the selected columns in the header
        indices=()
        for col in "${selected_columns[@]}"; do
            col=$(echo "$col" | xargs)  # Trim whitespace
            found=0
            for i in "${!header_columns[@]}"; do
                # Extract just the column name without the data type
                header_col=$(echo "${header_columns[i]}" | awk '{print $1}')
                if [[ "$header_col" == "$col" ]]; then
                    indices+=("$i")
                    found=1
                    break
                fi
            done
            if [[ $found -eq 0 ]]; then
                echo "Column $col does not exist in table $table_name."
                return 1
            fi
        done
        # Print header row for the selected columns
        output=""
        for index in "${indices[@]}"; do
        echo "Index: $index"
            output+="${header_columns[index]},"
        done
        output=${output%,}  # Remove trailing comma
        echo "Header Output: $output"
        echo "$output" > result.txt
        echo "-------, -------, -------" >> result.txt
        # Print data rows for the selected columns
        while IFS=',' read -a row; do
        echo "Row: ${row[@]}"
            row_output=""
            for index in "${indices[@]}"; do
                row_output+="${row[index]},"
                echo "Row Output: $row_output"
            done
            row_output=${row_output%,}  # Remove trailing comma
            echo "row_output:::: $row_output"
            echo "$row_output" >> result.txt
        done <<< "$data"
        # Use the `column` command to display the formatted output
        column -t -s ',' result.txt
        rm -f result.txt
   elif [[ "$select_query" =~ $regex ]]; then
        echo "Matched regex"
        # Extract components using regex groups
        # Use awk to extract the components
        columns=$(echo "$select_query" | awk -F'SELECT | FROM' '{print $2}' | xargs)
        table_name=$(echo "$select_query" | awk -F'FROM | WHERE' '{print $2}' | xargs)
        where_clause=$(echo "$select_query" | awk -F'WHERE ' '{print $2}' | xargs)
        where_col=$(echo "$where_clause" | awk -F'= ' '{print $1}' | xargs)
        where_val=$(echo "$where_clause" | awk -F"= " '{print $2}' | awk -F"'" '{print $1}' | xargs)
        # Print the extracted values
        echo "Columns: $columns"
        echo "Table Name: $table_name"
        echo "Where Column: $where_col"
        echo "Where Value: $where_val"
        # Check if the table exists
        if [[ ! -f "$table_name" ]]; then
            echo "Table $table_name does not exist."
            return 1
        fi
        # Read the header and data
        header=$(head -1 "$table_name")
        data=$(tail -n +3 "$table_name")  # Skip header and separator line
        # Convert header to array
        IFS=',' read -a header_columns <<< "$header"
        # Convert selected columns to array
        IFS=',' read -a selected_columns <<< "$columns"
        # Check if the where column exists in the header
        if [[ ! " ${header_columns[@]} " =~ " ${where_col} " ]]; then
            echo "WHERE column $where_col does not exist in table $table_name."
            return 1
        fi
        # Find indices of selected columns and where column
        # Find the index of the where column
for i in "${!header_columns[@]}"; do
    # Extract just the column name without the data type
    header_col=$(echo "${header_columns[i]}" | awk '{print $1}')
    if [[ "$header_col" == "$where_col" ]]; then
        where_index="$i"
        break
    fi
done

# Find indices of selected columns
indices=()
for col in "${selected_columns[@]}"; do
    col=$(echo "$col" | xargs)  # Trim whitespace
    found=0
    for i in "${!header_columns[@]}"; do
        # Extract just the column name without the data type
        header_col=$(echo "${header_columns[i]}" | awk '{print $1}')
        if [[ "$header_col" == "$col" ]]; then
            indices+=("$i")
            found=1
            break
        fi
    done
    if [[ $found -eq 0 ]]; then
        echo "Column $col does not exist in table $table_name."
        return 1
    fi
done
        # Find the index of the where column
        for i in "${!header_columns[@]}"; do
            if [[ "${header_columns[i]}" =~ ^[[:space:]]*$where_col[[:space:]]*$ ]]; then
                where_index="$i"
                break
            fi
        done
        if [[ $where_index -eq -1 ]]; then
            echo "WHERE column $where_col does not exist in table $table_name."
            return 1
        fi
        # Print header
        header_output=""
        for index in "${indices[@]}"; do
            header_output+="${header_columns[index]},"
        done
        echo "${header_output%,}" > result.txt
        # Print separator
        separator=""
        for index in "${indices[@]}"; do
            separator+="-------,"
        done
        echo "${separator%,}" >> result.txt
        # Process and print matching rows
        while IFS="," read -ra row; do
                
            if [[ "${row[$where_index]}" =~ ^[[:space:]]*$where_val[[:space:]]*$ ]]; then
                row_output=""
                for index in "${indices[@]}"; do
            
                    row_output+="${row[index]},"
                done
                echo "${row_output%,}" >> result.txt
            fi
        done <<< "$data"
        # Display formatted result
        column -t -s ',' result.txt
        rm -f result.txt
    
    else
        echo "Invalid query"
    fi
}
# Run the function
# SelectRows


function DeleteRow(){

     ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"

    # DELETE FROM Employees WHERE Department = 'HR' AND Salary > 52000
    regex="^DELETE[[:space:]]+FROM[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]+WHERE[[:space:]]+(.+)$"

    # To read array of input
    read  -p "Enter your Delete query: " query
    
    # Validate and extract table name and conditions

    if [[ $query =~ $regex ]]; then
        table_name="${BASH_REMATCH[1]}"
        conditions="${BASH_REMATCH[2]}"
    else
        echo "Invalid DELETE query syntax."
        exit 1
    fi

    echo "Table Name: $table_name"

    # columnss=$(echo "$conditions" | awk -F'=' '{print $3}' | xargs)
    # echo "colllllllllllllmns $columnss" 
    
    # Extract the column-value pairs from the conditions
    IFS='AND' read -r -a condition_array <<< "$conditions"

    echo "Conditions:"
    valuess=""
    for condition in "${condition_array[@]}"; do
        # Trim spaces around the condition
        condition=$(echo "$condition" | xargs)

        # Extract column name and value
        if [[ $condition =~ ^([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            column="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            echo "colllllllll $column"
            echo "valllllllllll $value"
            # Remove quotes from string values
            value=$(echo "$value" | sed "s/^'//;s/'$//")
            valuess+="$value "
            echo " $value"
        # else
            # echo "Invalid condition: $condition"
        fi
    done

    echo "valesssssssssssssss$valuess"

   pattern=$(echo "$valuess" | sed 's/ /.*, /g')
    pattern=$(echo "$pattern" | sed 's/, $//')
    echo "patterrrrrrrrrrrrn $pattern"
    sed -i "/$pattern/d" "$table_name" &&
      echo "Query executed SUCCESSFULLY" &&
     return 0;


    # Check the table is exists or not
    if [[ ! -e "${delete_query[0]}" ]]; then 
        echo "The table ${delete_query[0]} NOT EXITS";
        return 1;
    fi

    # Check values(array) number > or < the columns number
    # Check values data types 
    # Check columns names
    # Check values using regular expression (?, *, _, ...)
    # add LIMIT feature

    # sed  '/value1.*value2.*value3/d' example.txt (to check values in any order)
    # sed  '/value1 value2 value3/d' example.txt   (to check  values in order)
        ## we have to redirect the output to the table file using (>) because
            ## sed command just make this edit in buffer and display this on terminal
        ## (ORRRRRR) use -i option it apply the changes on the file directly
    # pattern="${delete_query[1]} ${delete_query[2]}$"
    # sed -i "/${pattern}/d" "${delete_query[0]}" &&
    #  echo "Query executed SUCCESSFULLY" &&
    #  return 0;

    # echo "FAILED to executed your query '${delete_query[0]}'." &&
    # return 1;

    return 0;
}

# DeleteRow

function UpdateRow(){
   ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    # query = UPDATE Employees SET Salary = 45000 WHERE Name = 'Steve'  AND Department = 'HR'

    

    # To read array of input
    read  -p "Enter your update query: " query
    


    # Store the query in a variable with proper quoting
    # local query="UPDATE Employees SET Salary = 45000 WHERE Name = 'Steve' AND Department = 'HR'"

    echo "Processing query: $query"

    # Updated regex pattern with more flexible whitespace handling
    local regex='^[[:space:]]*UPDATE[[:space:]]+([[:alnum:]_]+)[[:space:]]+SET[[:space:]]+([[:alnum:]_]+[[:space:]]*=[[:space:]]*[^[:space:]]+)[[:space:]]+WHERE[[:space:]]+([[:alnum:]_]+[[:space:]]*=[[:space:]]*'"'[^']*'"'([[:space:]]+AND[[:space:]]+[[:alnum:]_]+[[:space:]]*=[[:space:]]*'"'[^']*'"')*)[[:space:]]*$'

    if [[ "$query" =~ $regex ]]; then
        table_name="${BASH_REMATCH[1]}"
        set_clause="${BASH_REMATCH[2]}"
        where_clause="${BASH_REMATCH[3]}"
        
        echo "Table Name: $table_name"
        echo "SET Clause: $set_clause"
        echo "WHERE Clause: $where_clause"

        # Check if the table file exists
        if [[ ! -f "$table_name" ]]; then
            echo "Error: Table file '$table_name' does not exist."
            return 1
        fi

        # Parse SET clause
        if [[ $set_clause =~ ([[:alnum:]_]+)[[:space:]]*=[[:space:]]*([[:alnum:]]+) ]]; then
            set_column="${BASH_REMATCH[1]}"
            set_value="${BASH_REMATCH[2]}"
        else
            echo "Error: Invalid SET clause format"
            return 1
        fi

        # Parse WHERE clause and store conditions in arrays
        where_columns=()
        where_values=()
        
        # First condition
        if [[ $where_clause =~ ([[:alnum:]_]+)[[:space:]]*=[[:space:]]*\'([^\']+)\' ]]; then
            where_columns+=("${BASH_REMATCH[1]}")
            where_values+=("${BASH_REMATCH[2]}")
        fi
        
        # Second condition (after AND)
        if [[ $where_clause =~ AND[[:space:]]+([[:alnum:]_]+)[[:space:]]*=[[:space:]]*\'([^\']+)\' ]]; then
            where_columns+=("${BASH_REMATCH[1]}")
            where_values+=("${BASH_REMATCH[2]}")
        fi

        # Debug output
        echo "SET Column: $set_column"
        echo "SET Value: $set_value"
        echo "WHERE Columns: ${where_columns[*]}"
        echo "WHERE Values: ${where_values[*]}"

        IFS=" " read -ra set_columns_defintions <<< "$set_column"
        IFS=" " read -ra set_values_defintions <<< "$set_value"

    primary_key=$(grep -w "$table_name" tb_col_types.sh | cut -d":" -f"2" | head -n 1)
    echo "PPPPPPrimary_KKKKKKeYYYY::::::::::::::::::   $primary_key"
    # Validate the column values
    echo "columns::::::: $set_columns_defintions"
    echo "values::::::: $set_values_defintions"
    for i in "${!set_column[@]}"; do
        # Remove extra spaces
        col_name=$(echo "${set_column[i]}" | xargs)
        col_value=$(echo "${set_value[i]}" | xargs)
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
    done

        # Create temporary file for output
        local temp_file=$(mktemp)

        # Process the file using awk
        awk -v FS="," -v OFS="," \
            -v set_col="$set_column" \
            -v set_val="$set_value" \
            -v col1="${where_columns[0]}" \
            -v val1="${where_values[0]}" \
            -v col2="${where_columns[1]}" \
            -v val2="${where_values[1]}" '
        BEGIN {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", set_col)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", col1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", col2)
        }
        NR == 1 {
            # Process header
            for (i = 1; i <= NF; i++) {
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
                header_pos[$i] = i
            }
            print
            next
        }
        {
            # Process data rows
            match_row = 1
            
            # Check first condition
            if (!(col1 in header_pos)) {
                print "Column not found: " col1 > "/dev/stderr"
                exit 1
            }
            col1_idx = header_pos[col1]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $col1_idx)
            if ($col1_idx != val1) {
                match_row = 0
            }
            
            # Check second condition if exists
            if (match_row && col2 != "") {
                if (!(col2 in header_pos)) {
                    print "Column not found: " col2 > "/dev/stderr"
                    exit 1
                }
                col2_idx = header_pos[col2]
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", $col2_idx)
                if ($col2_idx != val2) {
                    match_row = 0
                }
            }
            
            if (match_row) {
                # Apply update
                if (!(set_col in header_pos)) {
                    print "Column not found: " set_col > "/dev/stderr"
                    exit 1
                }
                $header_pos[set_col] = set_val
            }
            print
        }' "$table_name" > "$temp_file"

        if [ $? -eq 0 ]; then
            mv "$temp_file" "$table_name"
            echo "Update completed successfully"
        else
            rm "$temp_file"
            echo "Error during update"
            return 1
        fi
    else
        echo "Error: Invalid UPDATE query syntax"
        echo "Query format should be: UPDATE table SET column = value WHERE column = 'value' [AND column = 'value']"
        return 1
    fi


}

# UpdateRow



# # Function to handle the main menu choices
# function HandleMainMenuChoice() {
#     case $1 in
#         1)
#             echo "Create Database selected"
#             CreateDatabase
#             ;;
#         2)
#             echo "List Databases selected"
#             ListDatabases
#             ;;
#         3)
#             echo "Connect to a Database selected"
#             ConnectToDatabases
#             ;;
#         4)
#             echo "Drop a Database selected"
#             DropDatabase
#             ;;
#         *)
#             echo "Invalid choice"
#             ;;
#     esac
# }

# # Function to handle the connect database menu choices
# function HandleConnectDatabaseMenuChoice() {
#     case $1 in
#         1)
#             echo "Create Table selected"
#             CreateTable
#             ;;
#         2)
#             echo "List Tables selected"
#             ListTables
#             ;;
#         3)
#             echo "Drop Table selected"
#             DropTable
#             ;;
#         4)
#             echo "Insert Row into Table selected"
#             InsertRow
#             ;;
#         5)
#             echo "Select Row from Table selected"
#             SelectRow
#             ;;
#         6)
#             echo "Delete Row from Table selected"
#             DeleteRow
#             ;;
#         7)
#             echo "Update Row in Table selected"
#             UpdateRow
#             ;;
#         *)
#             echo "Invalid choice"
#             ;;
#     esac
# }

# # Function to validate database name
# function ValidateDatabaseName() {
#     local db_name=$1
#     if [[ -d "$db_name" ]]; then
#         echo "Connected to database: $db_name SUCCESSFULLY"
#         cd "$db_name" || { echo "Failed to change directory"; return 1; }
#         return 0
#     else
#         echo "Database '$db_name' does not exist."
#         return 1
#     fi
# }

# # Main script execution
# while true; do
#     MainMenu
#     read -p "Enter your choice: " main_choice
#     if [[ $main_choice -ne 3 ]]; then
#         HandleMainMenuChoice $main_choice
#     elif [[ $main_choice -eq 3 ]]; then
#         while true; do
#             read -p "Enter the database name that you want CONNECT to it: " db_name
#             if ValidateDatabaseName "$db_name"; then
#                 while true; do
#                     ConnectDatabaseMenu
#                     read -p "Enter your choice: " connect_choice
#                     HandleConnectDatabaseMenuChoice $connect_choice
#                     break
#                 done
#                 break
#             else
#                 echo "Please enter a valid database name."
#             fi
#         done
#     fi
# done



function ConnectDatabaseMenu(){
    echo "  Connect to Database Menu"
    echo "----------------"

    # Validation cases to check user privileges can be added here

    echo "Write a number from the Menu: "
    echo "1)  Create Table"
    echo "2)  List Tables"
    echo "3)  Drop Table"
    echo "4)  Insert Row into Table"
    echo "5)  Select Row from Table"
    echo "6)  Delete Row from Table"
    echo "7)  Update Row in Table"
    echo "8)  Back to Main Menu"
    echo "
    -------------------------------
    "
}

# Function to handle the main menu choices
function HandleMainMenuChoice() {
    case $1 in
        1)
            echo "Create Database selected"
            CreateDatabase
            ;;
        2)
            echo "List Databases selected"
            ListDatabases
            ;;
        3)
            echo "Connect to a Database selected"
            ConnectToDatabases
            ;;
        4)
            echo "Drop a Database selected"
            DropDatabase
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

# Function to handle the connect database menu choices
function HandleConnectDatabaseMenuChoice() {
    case $1 in
        1)
            echo "Create Table selected"
            # Call the function to create a table
            CreateTable
            ;;
        2)
            echo "List Tables selected"
            # Call the function to list tables
            ListTables
            ;;
        3)
            echo "Drop Table selected"
            # Call the function to drop a table
            DropTable
            ;;
        4)
            echo "Insert Row into Table selected"
            # Call the function to insert a row into a table
            InsertRow
            ;;
        5)
            echo "Select Row from Table selected"
            # Call the function to select a row from a table
            SelectRow
            ;;
        6)
            echo "Delete Row from Table selected"
            # Call the function to delete a row from a table
            DeleteRow
            ;;
        7)
            echo "Update Row in Table selected"
            # Call the function to update a row in a table
            UpdateRow
            ;;
        8)
            echo "Back to Main Menu selected"
            return 1
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
    return 0
}

# Main script execution
while true; do
    MainMenu
    read -p "Enter your choice: " main_choice
    if [[ $main_choice -ne 3 ]]; then
        HandleMainMenuChoice $main_choice
    elif [[ $main_choice -eq 3 ]]; then
        while true; do
            read -p "Enter the database name that you want CONNECT to it: " db_name
            if [[ -d "$db_name" ]]; then
                cd "$db_name" || { echo "Failed to change directory"; break; }
                echo "Connected to database: $db_name SUCCESSFULLY"
                while true; do
                    ConnectDatabaseMenu
                    read -p "Enter your choice: " connect_choice
                    if ! HandleConnectDatabaseMenuChoice $connect_choice; then
                        break
                    fi
                done
                break
            else
                echo "Please enter a valid database name."
            fi
        done
    fi
done









