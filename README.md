# bufclean.nvim

Clean bufferes that are irrelevant to your current context.

## Features

- Clean buffers that are outside the directory of your current file
  - e.g. if you're working in src/ui/login.ts, close that src/db/user.ts file
  you opened to check the schema for
- Clean buffers irrelevant to the context currently visible
 - e.g. you are looking at src/ui/login.ts and test/ui/login.test.ts, close
  src/db/user.ts because it is hidden and not part of the current paths being
  looked at
- Clean all buffers related to the current focus' context
  - e.g. you're in src/ui/user.ts and want to clean that buffer, along side
  src/ui/login.ts

## Setup


```vim
Plug 'EthanJWright/bufclean.nvim'
```

## Functions

```vim
-- close any hidden buffers that are outside the top 2 directories of open
lua require('bufclean.clean').close_hidden_outside_visible_context(2)

-- close any files outside the top 2 directories of your currently focused
-- buffer
lua require('bufclean.clean').close_buffers_outside_context(2)


-- close any files that are within 2 shared directories of your currently
-- focuesd buffer
lua require('bufclean.clean').close_buffers_in_context(2)
```

## Examples

### Using include_from_cwd = true

(similar to cd ~/myproject)
This starts the parent_dir count from the current working directory

Params:
include_from_cwd = true
parent_dir = 2

cwd: ./myproject
buf1: ./myproject/src/user/login.ts
buf2: ./myproject/src/user/info.ts
buf3: ./myproject/src/db/login.ts

close_buffers_outside_context(2, true)
-> deletes buf3, because buf1 and buf2 share 2 parent directories above the cwd

### Using include_from_cwd = false

(similar to cd ../..)
This goes back directories from the current buffer

include_from_cwd = false
parent_dir = 2

cwd: ./myproject
buf1: ./myproject/src/user/login.ts
buf2: ./myproject/src/user/info.ts
buf3: ./myproject/src/db/login.ts
-> deletes no buffer, because they share a parent directory 2 levels up
