#!/bin/bash

echo "  Main Menu";
echo "----------------";

echo "Write a number from the Menu: ";

echo "1)  Create Database";
echo "2)  List Databases";
echo "3)  Connect to a Database";
echo "4)  Drop a Database";
echo "
-------------------------------
"

function ListDatabases(){
    
    echo "Your Databases : "

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

