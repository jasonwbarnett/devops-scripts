# DevOps Scripts

I created this repo to keep track of extremely useful scripts and to hopefully
add some benefit to others. Please feel free to fork / contribute.

## master_functions.sh functions

### ask_question

Asks a question and echoes the user input.

### ask_yes_no

Asks a yes/no question and echoes `true` or `false`. It will continue to ask
the user for input until they respond with one of the folllwing: `y`, `yes`,
`n` or `no`.

### downcase

Replaces all uppercase letters with their lowercase counterparts.

```bash
#!/bin/bash

echo "Hello Motto" | downcase
# => hello motto
```

### err_msg

### fail_msg

### gsub

### lstrip

Removes all leading whitespace. See also `rstrip` and `strip`.

```bash
#!/bin/bash

echo " Hello Motto" | lstrip
# => Hello Motto
```

### msg

### rstrip

Removes all trailing whitespace. See also `lstrip` and `strip`.

```bash
#!/bin/bash

echo "Hello Motto " | rstrip
# => Hello Motto
```

### strip

Removes all leading and trailing whitespace.

Whitespace is defined as any of the following characters: null, horizontal tab,
line feed, vertical tab, form feed, carriage return, space.

```bash
#!/bin/bash

echo " Hello Motto " | strip
# => Hello Motto
```

### succ_or_fail

### upcase

Replaces all lowercase letters with their uppercase counterparts.

```bash
#!/bin/bash

echo "Hello Motto" | upcase
# => HELLO MOTTO
```
