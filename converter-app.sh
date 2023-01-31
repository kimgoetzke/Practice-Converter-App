#!/usr/bin/env bash
set -euo pipefail

# Regex to validate conversion units, ratios, and rows
re_units='^[A-Za-z]+_to_[A-Za-z]+$'
re_ratio='^-?[0-9]+\.?[0-9]*?$'
re_row='^-?[0-9]+$'

# Create file, if required, and check length
file_name="definitions.txt"
touch $file_name

convert() {
  file_length=$(wc -l < $file_name)
  if [[ ! "$file_length" -gt "0" ]]; then

    # 1 Return if no definitions exist yet
    echo "Please add a definition first!"

  else

    # 2 Read definitions from file and display
    echo "Type the line number to convert units or '0' to return"
    local n=0
    while read line; do
      echo "$(( n += 1 )). $line"
    done < $file_name

    # 3 Select definition (and do conversion)
    while true; do
      read line_number
      if [[ $line_number == 0 ]]; then 
        break
      elif [[ "$line_number" -gt "0" ]] && [[ "$line_number" -le "$file_length" ]]; then

        # 4 Read conversion constant from file
        local line=$(sed "${line_number}!d" "$file_name")
        read -a text <<< "$line"
        local constant="${text[1]}"

        # 5 Request value to convert
        echo "Enter a value to convert: "
        while true; do
          read value
          if [[ "$value" =~ $re_ratio ]]; then

            # 6 Do the conversion
            result=$(echo "$constant * $value" | bc -l)
            printf "Result: %s\n" "$result"
            break

          fi
          echo "Enter a float or integer value!"
        done
        break

      else
        echo "Enter a valid line number!"
      fi
    done

  fi
}

add_definition() {
  local units ratio
  while true; do
    echo "Enter a definition:"
    read units ratio

    # Validate input and if successful, add to file
    if [[ "$units" =~ $re_units ]] && [[ "$ratio" =~ $re_ratio ]]; then
      echo -e "$units $ratio" >> $file_name
      break
    else
      echo "The definition is incorrect!"
    fi

  done
}

delete_definition() {
  file_length=$(wc -l < $file_name)
  if [[ ! "$file_length" -gt "0" ]]; then
    echo "Please add a definition first!"
  else
    echo "Type the line number to delete or '0' to return"

    # Print file with number prefix
    local n=0
    while read line; do
      echo "$(( n += 1 )). $line"
    done < $file_name

    # Prompt to ask for definition to delete (validate input and delete)
    while true; do
      read delete_me
      if [[ $delete_me == 0 ]]; then 
        break
      elif [[ "$delete_me" -gt "0" ]] && [[ "$delete_me" -le "$file_length" ]]; then
        sed -i "${delete_me}d" $file_name
        break
      else
        echo "Enter a valid line number!"
      fi
    done

  fi
}

show_menu() {
  echo -e "\nSelect an option"
  echo "0. Type '0' or 'quit' to end program"
  echo "1. Convert units"
  echo "2. Add a definition"
  echo "3. Delete a definition"
}

echo "Welcome to the simple converter!"
while true; do
  show_menu && read option
  case $option in
    "0" | "quit" ) echo -e "\nGoodbye!"; break;;
    "1" ) convert;;
    "2" ) add_definition;;
    "3" ) delete_definition;;
     *  ) echo "Invalid option!"
  esac
done
