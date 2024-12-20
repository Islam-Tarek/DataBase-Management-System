function SelectRows() {
    #   SELECT * FROM table_name;
    regex_all="^SELECT[[:space:]]*[*][[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    # SELECT PersonID, LastName, City FROM Persons
    regex_some_col="^SELECT[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*,?[[:space:]]*)+[[:space:]]+FROM[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*$"
    # SELECT PersonID, LastName, FirstName, Address FROM Persons WHERE City = 'Lala land2'
    regex="SELECT\s+.*?\s+FROM\s+\w+\s+WHERE\s+.*?"

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
        columns=$(echo "$select_query" | awk -F'SELECT' '{print $2}' | awk -F'FROM' '{print $1}' | xargs)
        
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
        data=$(tail -n +3 "$table_name")  # Skip header and separator line
        # Convert header to an array
        IFS=',' read -ra header_columns <<< "$header"
        
        # Convert selected columns to an array
        IFS=',' read -ra selected_columns <<< "$columns"
        
        # Find indices of the selected columns in the header
        indices=()
        for col in "${selected_columns[@]}"; do
            found=0
            for i in "${!header_columns[@]}"; do
                if [[ "${header_columns[i]}" =~ ^[[:space:]]*$col[[:space:]]*$ ]]; then
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
            output+="${header_columns[index]},"
        done
        output=${output%,}  # Remove trailing comma
        echo "$output" > result.txt
        echo "-------, -------, -------" >> result.txt
        # Print data rows for the selected columns
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
        indices=()
        where_index=-1
        for col in "${selected_columns[@]}"; do
            col=$(echo "$col" | xargs)  # Trim whitespace
            found=0
            for i in "${!header_columns[@]}"; do
                if [[ "${header_columns[i]}" =~ ^[[:space:]]*$col[[:space:]]*$ ]]; then
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
SelectRows
