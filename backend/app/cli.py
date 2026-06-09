import argparse
import sys

from app.core.exceptions import DomainError
from app.db.session import SessionLocal
from app.services.auth import create_admin_user


def create_admin(args: argparse.Namespace) -> int:
    with SessionLocal() as db:
        try:
            user = create_admin_user(
                db,
                email=args.email,
                password=args.password,
                full_name=args.full_name,
            )
        except DomainError as exc:
            print(exc.message, file=sys.stderr)
            return 1
    print(f"Admin ready: {user.email}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="pedido-local")
    subparsers = parser.add_subparsers(dest="command", required=True)

    admin_parser = subparsers.add_parser("create-admin")
    admin_parser.add_argument("--email", required=True)
    admin_parser.add_argument("--password", required=True)
    admin_parser.add_argument("--full-name", required=True)
    admin_parser.set_defaults(func=create_admin)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
