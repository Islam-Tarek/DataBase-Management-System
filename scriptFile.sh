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
        if [[ -d $database_name ]]; 
        then
            echo "$database_name"
        fi
    done
    exit 0
}



