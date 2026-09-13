# sgditto test report

Generated from the raw path lists in `tests/data/` by running
`tests/generate_report.sh`. Each section shows the raw input
(a path list, as `find .` would produce) and the tree sgditto
builds from it.

## basic tree

Input (`tests/data/01_basic_tree.txt`), command: `sgditto`:

```
./README.md
./src
./src/main.py
./src/models
./src/models/user.py
./src/utils
./src/utils/helper.py
./src/utils/other.py
./tests
./tests/test_main.py
```

Output:

```
.
  README.md
  src
    main.py
    models
      user.py
    utils
      helper.py
      other.py
  tests
    test_main.py
```

## no dot slash prefix

Input (`tests/data/02_no_dot_slash_prefix.txt`), command: `sgditto`:

```
README.md
src
src/main.py
src/models
src/models/user.py
src/utils
src/utils/helper.py
src/utils/other.py
tests
tests/test_main.py
```

Output:

```
README.md
src
  main.py
  models
    user.py
  utils
    helper.py
    other.py
tests
  test_main.py
```

## dot as root

Input (`tests/data/03_dot_as_root.txt`), command: `sgditto`:

```
.
./README.md
./src
./src/main.py
./src/utils
./src/utils/helper.py
```

Output:

```
.
  README.md
  src
    main.py
    utils
      helper.py
```

## custom separator

Input (`tests/data/04_custom_separator.txt`), command: `sgditto -s ::`:

```
root::README.md
root::src
root::src::main.py
root::src::utils
root::src::utils::helper.py
```

Output:

```
root
  README.md
  src
    main.py
    utils
      helper.py
```

## custom indent char

Input (`tests/data/05_custom_indent_char.txt`), command: `sgditto -i > -n 1`:

```
./README.md
./src
./src/main.py
./src/utils
./src/utils/helper.py
```

Output:

```
.
>README.md
>src
>>main.py
>>utils
>>>helper.py
```

## gron style

Input (`tests/data/06_gron_style.txt`), command: `sgditto -g -s .`:

```
json = {};
json.authors = [];
json.authors[0] = "Soheil";
json.config = {};
json.config.indent = " ";
json.config.separator = "/";
json.name = "sgditto";
json.version = "1.0";
```

Output:

```
json = {};
  authors = [];
  authors[0] = "Soheil";
  config = {};
    indent = " ";
    separator = "/";
  name = "sgditto";
  version = "1.0";
```
