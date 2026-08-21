#!/usr/bin/env python3
"""Upload the mapped SkyWars sounds to your Roblox account.

You run this yourself; the .ROBLOSECURITY cookie never leaves your machine.
Usage:
    ROBLOSECURITY='_|WARNING:-DO-NOT-SHARE...' python3 upload_sounds.py [folder]
or put the cookie in ./cookie.txt next to this script.

The cookie must be prefixed with ".ROBLOSECURITY=" (or the raw value works too).
Outputs new-ids.json (old_id -> new_id) which you hand back for the
roblox-sound.luau patch.

Expect the usual constraints: audio uploads are rate limited and monthly
capped, and new audio passes moderation (may reject copyrighted matches).
"""

import json
import os
import re
import sys
import time

import requests

PRIMARY_URL = "https://apis.roblox.com/assets/user-auth/v1/assets"
FALLBACK_URL = "https://apis.roblox.com/v1/assets/upload"
USER_URL = "https://users.roblox.com/v1/users/authenticated"

DELAY = 2.0  # seconds between uploads (be polite; avoid 429s)


def get_cookie():
    raw = os.environ.get("ROBLOSECURITY", "")
    if not raw and os.path.exists("cookie.txt"):
        with open("cookie.txt") as f:
            raw = f.read().strip()
    raw = raw.strip()
    if not raw:
        sys.exit("Set the ROBLOSECURITY env var or write ./cookie.txt")
    if raw.startswith(".ROBLOSECURITY="):
        return raw
    return ".ROBLOSECURITY=" + raw


def get_csrf(session, headers):
    # POSTing without a token returns the token in the X-CSRF-TOKEN header
    resp = session.post(PRIMARY_URL, headers=headers)
    token = resp.headers.get("X-CSRF-TOKEN")
    if not token:
        sys.exit(f"Could not get CSRF token (HTTP {resp.status_code}). Cookie likely invalid/expired.")
    return token


def get_user_id(session, headers):
    resp = session.get(USER_URL, headers=headers)
    if resp.status_code != 200:
        sys.exit(f"Authenticated user check failed: HTTP {resp.status_code} {resp.text[:200]}")
    return resp.json().get("id")


def extract_asset_id(response_text):
    """Parse the new asset id out of the upload response."""
    try:
        data = json.loads(response_text)
    except json.JSONDecodeError:
        return None
    if isinstance(data, dict):
        for key in ("assetId", "assetID", "id"):
            value = data.get(key)
            if isinstance(value, int):
                return str(value)
        for key, value in data.items():
            if "assetid" in key.lower() and isinstance(value, int):
                return str(value)
        # nested: {"asset": {"assetId": ...}} style
        for sub in data.values():
            if isinstance(sub, dict):
                found = extract_asset_id(json.dumps(sub))
                if found:
                    return found
    return None


def upload(session, headers, user_id, filepath, display_name):
    def attempt(url):
        with open(filepath, "rb") as audio:
            files = {"fileContent": (os.path.basename(filepath), audio, "audio/ogg")}
            data = {
                "request": json.dumps(
                    {
                        "displayName": display_name,
                        "description": "SkyWars SEASON 3 sound (local reconstruction)",
                        "assetType": "Audio",
                        "creationContext": {"creator": {"userId": user_id}, "expectedPrice": 0},
                    }
                )
            }
            return session.post(url, headers=headers, files=files, data=data)

    resp = attempt(PRIMARY_URL)
    if resp.status_code == 403 and "X-CSRF-TOKEN" in resp.headers:
        headers["X-CSRF-TOKEN"] = resp.headers["X-CSRF-TOKEN"]
        resp = attempt(PRIMARY_URL)
    if resp.status_code == 200:
        return resp.text
    resp = attempt(FALLBACK_URL)
    if resp.status_code == 403 and "X-CSRF-TOKEN" in resp.headers:
        headers["X-CSRF-TOKEN"] = resp.headers["X-CSRF-TOKEN"]
        resp = attempt(FALLBACK_URL)
    if resp.status_code == 200:
        return resp.text
    return None


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else "mapped"
    if not os.path.isdir(folder):
        sys.exit(f"Folder not found: {folder}")

    files = sorted(f for f in os.listdir(folder) if f.lower().endswith(".ogg"))
    if not files:
        sys.exit(f"No .ogg files in {folder}")
    print(f"Found {len(files)} sounds to upload.")

    cookie = get_cookie()
    session = requests.Session()
    headers = {
        "Cookie": cookie,
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) skywars-sound-uploader/1.0",
    }
    headers["X-CSRF-TOKEN"] = get_csrf(session, headers)
    user_id = get_user_id(session, headers)
    print(f"Authenticated as user {user_id}")

    mapping = {}
    failures = []
    for index, filename in enumerate(files, start=1):
        match = re.match(r"^(\d+)_(.+)\.ogg$", filename)
        old_id, key = (match.group(1), match.group(2)) if match else ("?", filename)
        display_name = key if key != "?" else os.path.splitext(filename)[0]
        print(f"[{index}/{len(files)}] uploading {filename} (id {old_id}, name '{display_name}') ...", flush=True)
        response = upload(session, headers, user_id, os.path.join(folder, filename), display_name)
        if response is None:
            print("    FAILED (see nothing? primary+fallback rejected)")
            failures.append(filename)
        else:
            new_id = extract_asset_id(response)
            if new_id:
                mapping[old_id] = new_id
                print(f"    OK -> new id {new_id}")
            else:
                print(f"    UPLOADED but response unparsed: {response[:160]}")
                failures.append(filename)
        time.sleep(DELAY)

    with open("new-ids.json", "w") as f:
        json.dump(mapping, f, indent=1)
    print(f"\nDone. {len(mapping)} mapped, {len(failures)} failed.")
    if failures:
        print("Failed:", failures)
    print("Mapping written to new-ids.json — send that file (or its contents) back.")


if __name__ == "__main__":
    main()
