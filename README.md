# ssh-copy-id

Dead simple, version of [shh-copy-id](https://www.man7.org/linux/man-pages//man1/ssh-copy-id.1.html)
for Windows with one line setup.

written in Python :snake:

## How to install?

Just run:

```bash
powershell -ExecutionPolicy ByPass -c "irm https://anytokin.github.io/shh-copy-id/install.ps1 | iex"
```

or download portable version:

[![Download](https://img.shields.io/badge/Download-ssh--copy--id.exe-blue?style=for-the-badge&logo=github)](https://github.com/anytokin/shh-copy-id/releases/latest/download/ssh-copy-id.exe)


## How to use?

Simply:

```bash
ssh-copy-id
```

Script will prompt for user and hostname

Alternatively:

- provide just host
    ```bash
    ssh-copy-id host
    ```

- provide user@host
    ```bash
    ssh-copy-id user@host 
    ```

- Use with options:<br><br>
-i &ensp;[_identity_file_]
<br>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Use only the key(s) contained in _identity_file_ (rather
               default _~/.ssh/id_rsa.pub_).<br><br>
-n &ensp;&ensp;Do a dry-run. Instead of installing keys on the remote
               system simply prints the key(s) that would have been
               installed.<br><br>
-t &ensp;[_target_path_]
<br>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;The path on the target system where the keys should be
               added (defaults to "_.ssh/authorized_keys_").<br><br>
-p &ensp;[_port_]
<br>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Specifies the port to connect to on the remote host.<br><br>
-v &ensp;&ensp;Return ssh-copy-id version.<br><br>
-x &ensp;&ensp;This option is for debugging the ssh-copy-id script
               itself.

## Help

```bash
ssh-copy-id -h
```

## Any issues?

Reach me via GitHub issues or directly [dawid.kohnke.cad@gmail.com](mailto:dawid.kohnke.cad@gmail.com)