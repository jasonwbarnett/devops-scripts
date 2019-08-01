# DevOps Scripts

I created this repo to keep track of extremely useful scripts and to hopefully
add some benefit to others. Please feel free to fork / contribute.

## master_functions.sh

### ask_question

Asks a question and returns the user input.

### ask_yes_no

Asks a yes/no question and returns `true` or `false`. It will continue to ask
the user for input until they respond with one of the folllwing: `y`, `yes`,
`n` or `no`.

```bash
#!/bin/bash
# filename: ask_yes_no_example.sh
source master_functions.sh

answer=$(ask_yes_no "Are you going to work today?")
if [[ $answer == true ]]; then
  echo "How wonderful! Have a great day off."
else
  echo "How sad :( -- try and make the best of it"
fi
```

```text
bash ./ask_yes_no_example.sh
Are you going to work today?: [y/n] y
How wonderful! Have a great day off.

$ bash ./ask_yes_no_example.sh
Are you going to work today?: [y/n] n
How sad :( -- try and make the best of it
```

### downcase

Replaces all uppercase letters with their lowercase counterparts.

### err_msg

### fail_msg

### gsub

### lstrip

Removes all leading whitespace. See also `rstrip` and `strip`.

### msg

### rstrip

Removes all trailing whitespace. See also `lstrip` and `strip`.

### strip

Removes all leading and trailing whitespace.

Whitespace is defined as any of the following characters: null, horizontal tab,
line feed, vertical tab, form feed, carriage return, space.

### succ_or_fail

### upcase

Replaces all lowercase letters with their uppercase counterparts.
