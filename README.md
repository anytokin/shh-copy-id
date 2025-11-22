# ssh-copy-id
Dead simple, version of [shh-copy-id](https://www.man7.org/linux/man-pages//man1/ssh-copy-id.1.html)
for Windows with one line setup.

written in Python :snake:

## How to install?
Just run in:
```bash
powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/anytokin/shh-copy-id/main/install.ps1 | iex"
```

or download it manually via releases tab.
## How to use?
Simply:
```bash
ssh-copy-id
```
Script will prompt for user and hostname 

Alternatively :
- provide just host
    ```bash
    ssh-copy-id host
    ```

- provide user@host
    ```bash
    ssh-copy-id user@host 
    ```
  
- Use with flags user@host
    ```bash
    ssh-copy-id user@host -p ssh_port -i path_to_public_key_file
    ```
## Help

```bash
ssh-copy-id -h
```

## Any issues?
Reach me via GitHub issues or directly [dawid.kohnke.cad@gmail.com](mailto:dawid.kohnke.cad@gmail.com)