#!/bin/env bash

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
    
    read -p "Enter Table Name: " table_name
     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.
    
    # 4- Check if there's a table with same name
    touch "$table_name" || { echo "FAILED to CREATE table"; return 1;}
    
    # Ask about columns number
    # Validate the columns data types

    echo "$table_name table is CREATED SUCCESSFULLY" 
    return 1;
}


function ListTables(){

     ## Need to write a validation cases to check 
        # the command executor is one of :
            # 1 - database owner  or root ?
            # 2 - this user in the owner group ? check the group privileges
            # 3 - others ? check the others privileges
        # AND SHOW THE OPTIONS THAT USER HAS PRIVILEGES TO DO IT.

    echo "All tables: "

    for table_name in `ls`;
    do
        if [[ -f "$table_name" ]]; then
            echo $table_name;
        fi
    done

    return 0;
}



