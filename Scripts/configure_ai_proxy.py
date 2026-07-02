#!/usr/bin/env python3
"""Configure YCAppStarter AI proxy client settings."""
import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"


def replace_string_literal(text: str, label: str, value: str) -> str:
    pattern = rf'({re.escape(label)}:\s*)"[^"]*"'
    return re.sub(pattern, lambda m: f'{m.group(1)}"{value}"', text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Configure AI proxy base URL and optional client token.")
    parser.add_argument("--base-url", required=True, help="AI proxy base URL, for example https://name.account.workers.dev")
    parser.add_argument("--client-token", default="", help="Optional X-Starter-Client-Token sent by the app.")
    parser.add_argument("--backend-base-url", default=None, help="Optional generic backend base URL. Defaults to --base-url.")
    args = parser.parse_args()

    text = SECRETS.read_text(encoding="utf-8")
    text = replace_string_literal(text, "openAIProxyBaseURL", args.base_url)
    text = replace_string_literal(text, "aiProxyClientToken", args.client_token)
    text = replace_string_literal(text, "backendBaseURL", args.backend_base_url or args.base_url)
    SECRETS.write_text(text, encoding="utf-8")
    print("Configured AI proxy settings in Sources/YCAppStarter/Config/AppSecrets.swift")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
