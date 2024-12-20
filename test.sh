#!/bin/bash

function UpdateRows() {
    # Store the query in a variable with proper quoting
    local query="UPDATE Employees SET Salary = 45000 WHERE Name = 'Steve' AND Department = 'HR'"

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

# Run the function
UpdateRows