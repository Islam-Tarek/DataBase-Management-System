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
    read -p "Enter the Database name that you want to connect to it: " db_connect_name

     for database_name in `ls`;
    do
        if [[ -d "$database_name" && "$database_name" = "$db_connect_name" ]]; then
            ## Need to write a validation cases to check 
                # the command executer is one of :
                    # 1 - database owner  or root ?
                    # 2 - this user in the owner group ? check the group privilages
                    # 3 - others ? and check the others privilages 

            cd "$database_name" || { echo "Failed to change directory"; return 1; }
            echo "Connected to database: $database_name"
            return 0;
        fi
    done 

    echo "Directory not found or not accessible."
}

