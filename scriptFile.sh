#!/bin/env bash


### Need switch..case to choose the operation

echo "  Main Menu";
echo "----------------";

    ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.

echo "Write a number from the Menu: ";

echo "1)  Create Database";
echo "2)  List Databases";
echo "3)  Connect to a Data";
echo "4)  Drop a Database";
echo "
-------------------------------
"

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

    for database_name in `ls`;
    do
        if [[ -d "$database_name" && "$database_name" = "$db_name_connect" ]]; then
            ## Need to write a validation cases to check 
                # the command executor is one of :
                    # 1 - database owner  or root ?
                    # 2 - this user in the owner group ? check the group privileges
                    # 3 - others ? check the others privileges 

            cd "$database_name" || { echo "Failed to change directory"; return 1; }
            echo "Connected to database: $database_name SUCCESSFULLY"
            return 0;
        fi
    done 

    echo "Directory not found or not accessible."
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
        
    mkdir "$db_name_create" || { echo "Faliled to CREATE this database"; return 1; }

    echo "$db_name_create database is CREATED SUCCESSFULLY"
    return 0;  
    
    echo "You are NOT accessible to CREATE database"
    return 1;
}   

### -----------------------------------------------------------------------------------


function ConnectDatabaseMenu(){
    
    ### Need switch..case to choose the operation

    echo "  Connect to Database Menu";
    echo "----------------";

    ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.

    echo "Write a number from the Menu: ";

    echo "1)  Create Table";   # --
    echo "2)  List Tables";    # --
    echo "3)  Drop Table";     # --
    echo "4)  Insert Row into Table"; #
    echo "5)  Select Row from Table";
    echo "6)  Delete Row from Table";
    echo "7)  Update Row in Table";
    
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
    
    # # 4- Check if there's a table with same name  ***
    # if [[ -f "$table_name_create" ]]; then
    #     echo "There's a FILE have SAME name" && return 1;
    # fi

    # touch "$table_name_create" || { echo "FAILED to CREATE table"; return 1;}
    
    # # Ask about columns number
    # echo "columns types is STRING -s or NUMBER -i"
    # echo "Enter each column name FOLLOWED by it's type seperated by a SPACE
    # -i for integers and -s for strings"
    
    read -p "Enter columns names: " query
    read -a create_tb_query <<< "$query"

    ################################# i'm working here
    ## CREATE TABLE table_name (
    ##    col1_name type,
    ##    col2_name type 
    ## )

    ## CREATE TABLE Persons ( PersonID INT, LastName VARCHAR(14), FirstName VARCHAR(255), Address VARCHAR(14), City VARCHAR(14) )

    ## Attempt 1:  ^CREATE[[:space:]]+TABLE[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(([^()]*VARCHAR[[:space:]]*\([[:space:]]*[0-9]+[[:space:]]*\)[^()]*)\)[[:space:]]*?$
    ## Attempt 2:  ^CREATE[[:space:]]+TABLE[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*[(][[:space:]]* +[a-zA-Z_][a-zA-Z0-9_]* (INT|VARCHAR) [,]* [[:space:]]* [)]
    
    ### Final Attempt : ^CREATE[[:space:]]+TABLE[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+(INT|VARCHAR\([[:space:]]*[0-9]{1,15}[[:space:]]*\))[[:space:]]*,?)+)\)[[:space:]]*;?$

   regex="^CREATE[[:space:]]+TABLE[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+(INT|VARCHAR\([[:space:]]*[0-9]{1,15}[[:space:]]*\))[[:space:]]*,?)+)\)[[:space:]]*?$"



    # Enhanced regex for CREATE TABLE validation
    if [[ $query =~ $regex ]]; then
        echo "Valid CREATE TABLE query."
      #  return 0
    else
        echo "Invalid CREATE TABLE query syntax."
        return 1
    fi

    tb_ref="tb_col_types.sh"
    tb_name="${create_tb_query[2]}"
    
    declare -A my_map;

    echo "declare -A $tb_name=(" >> "$tb_ref"

    col_name='';



    for element in "$create_tb_query";
    do
        if [[ "$element"=="VARCHAR" || "$element"=="INT" ]]; 
        then
            my_map["$col_name"]="$element"
            echo "    [\"$col_name\"]=\"$element\"" >> "$tb_ref" 
        else
            col_name="$element";
        fi
    done

    echo ")" >> "$tb_ref"

    echo "Map has been saved to $tb_ref"


    # if [[  ]]
    # declare -a tb_col_types
    # declare check_types
    # declare current_col

    # for col_name in tb_col_name; 
    # do  
    #     if[[ col_name != "-i" ]];
    #     then
    #         "${tb_col_name[$col_name]}"="i"
    #     ###########
    #     fi
    #          current_col="$col_name";
    # done

    # # Validate the columns data types
    # # Ask about PKs

    # echo "$table_name_create table is CREATED SUCCESSFULLY" 
    # return 1;
}

#####################################################################################################
######################################### need to validate the primary key
#####################################################################################################

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
    # Extract column definitions
    column_definitions="${BASH_REMATCH[2]}"

    tb_ref="tb_col_types.sh"


     # 4- Check if there's a table with same name  ***
    if [[ -f "$table_name_create" ]]; then
        echo "There's a FILE have SAME name" && return 1;
    fi

    touch "$table_name" || { echo "FAILED to CREATE table"; return 1;}

    # push table name in (allTables) file
    echo "$table_name" >> "allTables"

    # Initialize the associative array
    echo "declare -A $table_name=(" >> "$tb_ref"

    # Parse column definitions
    IFS=',' read -ra columns <<< "$column_definitions"
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
    echo "Map for table '$table_name' has been saved to $tb_ref."

    ## Need to create the table format using -----
}


#  CreateTable2


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
      ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
    
        # Check PKs values 
            ## need to make this check but it will done in the next version 


    ##### INSERT QUERY
    # CREATE TABLE Persons ( PersonID INT, LastName VARCHAR(14), FirstName VARCHAR(255), Address VARCHAR(14), City VARCHAR(14) )
    
    ##### INSERT INTO Persons (PersonID, LastName, FirstName, Address, City) VALUES (1, 'John', 'Doe', 'abcd,st', 'Lala land');
    ## 1- INSERT INTO Persons (PersonID, LastName, FirstName, Address, City) VALUES (1, 'John', 'Doe', 'abcdst', 'Lala land')
        ### regex1="^INSERT[[:space:]]+INTO[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*,?)+)\)[[:space:]]+VALUES[[:space:]]*\((([[:space:]]*('[^']*'|[0-9]+)[[:space:]]*,?)+)\)[[:space:]]*?$"

    ## 2- INSERT INTO Persons VALUES (1, 'John', 'Doe', 30);
        ### regex2="^INSERT[[:space:]]+INTO[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]+VALUES[[:space:]]*\((([[:space:]]*('[^']*'|[0-9]+)[[:space:]]*,?)+)\)[[:space:]]*?$"
            #### I will make validateion to this regex2 but in the next version

    ## Regex for validating the CREATE TABLE syntax
    regex1="^INSERT[[:space:]]+INTO[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\((([[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*,?)+)\)[[:space:]]+VALUES[[:space:]]*\((([[:space:]]*'([^']|'')*'|[0-9]+[[:space:]]*)[,]?)+\)[[:space:]]*?$"

    # To read array of input use -a option

    # read insert query
    read  -p "Enter your INSERT query:  " query
    
    if [[ $query =~ $regex1 ]];
    then
        echo "Valid INSERT ROW query."
    else
        echo "Invalid INSERT ROW query syntax"
        return 1;
    fi
    

###########################################################################
########################## The problem is here can't parse the columns and values correctly
#################################################################################################
    # Table name
    table_name=$(echo "$query" | awk -F'[()]' '{print $1}' | sed -E 's/^INSERT[[:space:]]+INTO[[:space:]]+//g' | xargs)
    # columns definations
    column_definitions=$(echo "$query" | awk -F'[()]' '{print $2}' | xargs)
    # get the values
    values=$(echo "$query" | awk -F'VALUES[[:space:]]*[(]' '{print $2}' | sed -E 's/[)]$//g' | xargs)

    echo "the table name isssssss: $table_name"


    echo "Table Name: $table_name"
    echo "Columns: $column_definitions"
    echo "Values: $values"

    # will load the table references to the file to check the columns type
    source ./tb_col_types.sh


    # tables reference
    table_ref="tb_col_types.sh"


    # Check the table is exists or not
    #check_table=`cat allTables | grep -w $table_name`
    
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
################################################## I'm here  need to make parsing for the query and insert it to the table
####################### and check columns types

   
    IFS=',' read -ra columns_array <<< "$column_definitions"
    IFS=',' read -ra values_array <<< "$values"

    for v in $columns_array;
    do
        echo "columns_arrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrray : $v"
    done

     # Check values(array) number > or < the columns number
    # check column count matches count

    echo "columns::::::: $columns"
    if [[ ${#columns_array[@]} -ne ${#values_array[@]} ]];
    then    
        echo "column count and values do not match."
        return 1;
    fi

    
    # Create a dynamic reference to the table metadata associative array
    declare -n table_metadata=$table_name

    # Ensure the table metadata exists
    if [[ -z "${table_metadata[@]}" ]]; then
        echo "No metadata found for table $table_name."
        return 1
    fi

    for i in "${!columns_array[@]}"; 
    do
        # Remove extra spaces
        col_name=$(echo "${columns_array[i]}" | xargs)
        col_value=$(echo "${values_array[i]}" | xargs)
        echo "The table name isss:::::::::: $table_name"
        
        # Check if the column exists in the table metadata
        if [[ -z "${table_metadata[$col_name]}" ]]; then
            echo "Column $col_name doesn't exist in table $table_name"
            return 1
        fi

        # Retrieve column type from metadata
        col_type="${table_metadata[$col_name]}"

        # Validate the value type
        if [[ "$col_type" == "INT" ]]; then
            if ! [[ "$col_value" =~ ^[0-9]+$ ]]; then
                echo "Value $col_value for column $col_name isn't of the type INT"
                return 1
            fi
        elif [[ "$col_type" =~ ^VARCHAR\(([0-9]+)\)$ ]]; then
            max_len="${BASH_REMATCH[1]}"
            if [[ ${#col_value} -gt $max_len ]]; then
                echo "Value $col_value for column $col_name exceeds VARCHAR($max_len) limit or is not a valid string"
                return 1
            fi
        else
            echo "Unknown column type $col_type for column $col_name"
            return 1
        fi
    done



    # append the row to the table file
    formated_values=`echo "$values" | awk '{gsub(",", " ", $0); print $0}'`
   
   echo "$formated_values" >> "$table_name" && 
   echo "New Row added SUCCESSFULLY to table $table_name" && 
   return 0;

    

        echo "FAILED to INSERT ROW IN $table_name table" && return 1;
}

# CreateTable2;
InsertRow;


function SelectRow(){
    ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"

    # To read array of input
    read  -a select_query
    
    # Check the table is exists or not
    if [[ ! -e "${select_query[0]}" ]]; then 
        echo "The table ${select_query[0]} NOT EXITS";
        return 1;
    fi

    # Check values(array) number > or < the columns number
    # Check values data types 
    # Check columns names
    # Check values using regular expressions (?, *, _, ...)
    # add LIMIT feature

    
    #Table name
    table_name="${select_query[0]}"
    
    # get all values
    search_values=("${select_query[@]:1}")
    
    # store the table data
    result=$(cat "$table_name")
    
    #Search about values
    for value_x in "${search_values[@]}";
    do
        result=$(echo "$result" | grep -w "$value_x")
    done

    if [[ `cat  "${select_query[0]}" ` = "$result" ]]; then
        # Need enhancement in the comment and validation why can't select
        echo "You can't select data from table ${select_query[0]}"
        return 1; 
    fi
    
    echo "Matched Rows: "
    echo "$result";
    return 0;
}


function DeleteRow(){

     ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"

    # To read array of input
    read  -a delete_query
    
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
    pattern="${delete_query[1]} ${delete_query[2]}$"
    sed -i "/${pattern}/d" "${delete_query[0]}" &&
     echo "Query executed SUCCESSFULLY" &&
     return 0;

    echo "FAILED to executed your query '${delete_query[0]}'." &&
    return 1;
}


function UpdateRow(){
   ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        
    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"

    # To read array of input
    read  -a update_query
    
    # Check the table is exists or not
    if [[ ! -e "${update_query[0]}" ]]; then 
        echo "The table ${update_query[0]} NOT EXITS";
        return 1;
    fi

    # Check values(array) number > or < the columns number
    # Check values data types 
    # Check columns names
    # Check values using regular expressions (?, *, _, ...)
    # add LIMIT feature

    
    #Table name
    table_name="${update_query[0]}"
    

    delete_operation=`awk -v col1="${update_query[1]}" -v col1_update="${update_query[2]}" \
        -v col2="${update_query[3]}" -v col2_update="${update_query[4]}" \
        '$0 ~ col1 && $0 ~ col2 {gsub(col1, col1_update); gsub(col2, col2_update)} {print}' "${update_query[0]}"`

    echo "$delete_operation" >  "${update_query[0]}" &&
    echo "Query executed SUCCESSFULLY" &&
    return 0;
        
    echo "FAILED to executed your query '${update_query[0]}'." &&
    return 1;

}

