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
echo "3)  Connect to a Database";
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

    echo "1)  Create Table";
    echo "2)  List Tables";
    echo "3)  Drop Table";
    echo "4)  Insert Row into Table";
    echo "5)  Select Row from Table";
    echo "6)  Delete Row from Table";
    echo "7)  Update Row in Table";
    
    echo "
    -------------------------------
    "
}


function CreateTable(){
    
    read -p "Enter Table Name: " table_name_create

     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.
    
    # 4- Check if there's a table with same name


    touch "$table_name_create" || { echo "FAILED to CREATE table"; return 1;}
    
    # Ask about columns number
    # Validate the columns data types
    # Ask about PKs

    echo "$table_name_create table is CREATED SUCCESSFULLY" 
    return 1;
}


function ListTables(){

     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges

    echo "All tables: "

    for table_name in `ls`;
    do
        if [[ -f "$table_name" ]]; then
            echo $table_name;
        fi
    done

    return 0;
}


function DropTable(){

    ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges

    read -p "Enter the Table name that you want DROP it: " table_name_drop

    rm -f "$table_name_drop" 

    delete_operation_stat=`echo $?`

    if [[ $delete_operation_stat = "0" ]]; then
        echo "$table_name_drop is DROPED SUCCESSFULLY"; return 0;
    else
        echo "FAILED to DROP $table_name_drop table"; return 1;
    fi

}   

function InsertRow(){
      ## Need to write a validation cases to check 
        # The command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges

    
    echo "Write table name then the table Rows in order Ex: (table_name row1_val row2_val ....)"

    # To read array of input
    read  -a insert_query
    
    # Check the table is exists or not
    if [[ ! -e "${insert_query[0]}" ]]; then 
        echo "The table ${insert_query[0]} NOT EXITS" && return 1;
    fi
    
    # Check values(array) number > or < the columns number
    # Check values data types 
    # Check PKs values

    echo "New row" >> "${insert_query[0]}" && 
        echo "New Row added SUCCESSFULLY";
    

    return 0;
}


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

DeleteRow
