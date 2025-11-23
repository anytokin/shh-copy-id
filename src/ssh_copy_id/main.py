import argparse
import subprocess
import sys
from pathlib import Path
from version import get_version


def parse_user_host(user_at_host: str | None) -> str:
    """
    Parse user@host. If missing parts, prompt interactively.
    """
    user = None
    host = None

    if user_at_host:
        if "@" in user_at_host:
            user, host = user_at_host.split("@", 1)
        else:
            # only user or only host was given
            if user_at_host.replace(".", "").isdigit():
                host = user_at_host
            else:
                user = user_at_host

    if not user:
        user = input("Enter SSH username: ").strip()

    if not host:
        host = input("Enter SSH host (IP or hostname): ").strip()

    return f"{user}@{host}"


def ssh_copy_id(**kwargs) -> None:
    user_at_host: str = parse_user_host(kwargs.get("user_at_host"))
    pubkey_path: Path = Path(kwargs.get("identity_file"))
    port: str = str(kwargs.get("port"))
    debug: bool = kwargs.get("x")
    dry_run: bool = kwargs.get("n")
    target_path: Path = Path(kwargs.get("t"))

    if not pubkey_path.exists():
        print(f"[!] Public key not found: {pubkey_path}")
        print("    Generate one with: ssh-keygen")
        sys.exit(1)

    key = pubkey_path.read_text().strip()
    if dry_run:
        print(key, end="")
        return

    remote_cmd = (
        "mkdir -p ~/.ssh && "
        "chmod 700 ~/.ssh && "
        f"echo '{key}' >> {target_path} && "
        f"chmod 600 {target_path}"
    )

    print(f"[+] Copying key to {user_at_host} ...")

    ssh_command = ["ssh", "-p", port, user_at_host, remote_cmd]
    if debug:
        print(f"Running: {" ".join(ssh_command)}")
    result = subprocess.run(
        ssh_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if result.returncode == 0:
        print("[✓] Public key added successfully.")
    else:
        print("[!] SSH command failed.")
        print(result.stderr)
        sys.exit(result.returncode)


def main():
    parser = argparse.ArgumentParser(description="Alternative for Linux's ssh-copy-id")
    parser.add_argument(
        "user_at_host",
        nargs="?",
        help="REMOTE_USER@REMOTE_HOST"
    )
    parser.add_argument(
        "-p", "--port",
        type=int,
        default=22,
        help="SSH port (default: 22)",
    )
    parser.add_argument(
        "-i", "--identity-file",
        default=str(Path.home() / ".ssh" / "id_rsa.pub"),
        help="Path to public key file (default: ~/.ssh/id_rsa.pub)"
    )
    parser.add_argument(
        "-x",
        action="store_true",
        help="Debugging the ssh-copy-id script itself"
    )

    parser.add_argument(
        "-n",
        action="store_true",
        help="""Do a dry-run. Instead of installing keys on the remote
               system simply prints the key(s) that would have been
               installed""",
    )
    parser.add_argument(
        "-t",
        type=str,
        default="~/.ssh/authorized_keys",
        help="""The path on the target system where the keys should be
               added (defaults to ".ssh/authorized_keys")"""
    )
    parser.add_argument(
        "-v",
        action='store_true',
        help="""Return ssh-copy-id version"""
    )

    args = parser.parse_args()
    if args.v:
        print(get_version(),end="")
        return
    ssh_copy_id(**args.__dict__)


if __name__ == "__main__":
    main()
