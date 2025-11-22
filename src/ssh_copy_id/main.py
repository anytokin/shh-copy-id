import argparse
import subprocess
import sys
from pathlib import Path


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


def ssh_copy_id(user_at_host: str, port: int, pubkey_path: Path):
    if not pubkey_path.exists():
        print(f"[!] Public key not found: {pubkey_path}")
        print("    Generate one with: ssh-keygen")
        sys.exit(1)

    key = pubkey_path.read_text().strip()

    remote_cmd = (
        "mkdir -p ~/.ssh && "
        "chmod 700 ~/.ssh && "
        f"echo '{key}' >> ~/.ssh/authorized_keys && "
        "chmod 600 ~/.ssh/authorized_keys"
    )

    print(f"[+] Copying key to {user_at_host} ...")

    result = subprocess.run(
        ["ssh", "-p", str(port), user_at_host, remote_cmd],
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

    args = parser.parse_args()
    user_host = parse_user_host(args.user_at_host)
    ssh_copy_id(user_host, args.port, Path(args.identity_file))


if __name__ == "__main__":
    main()
