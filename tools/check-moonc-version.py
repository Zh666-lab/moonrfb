#!/usr/bin/env python3
"""Enforce the hackathon's minimum MoonC compiler version."""
from __future__ import annotations
import re
import subprocess
import sys

minimum = (0, 10, 14)
text = subprocess.check_output(["moon", "version", "--all"], text=True, stderr=subprocess.STDOUT)
match = re.search(r"^moonc v(\d+)\.(\d+)\.(\d+)(?:[+\-].*)?$", text, re.MULTILINE)
if not match:
    print("could not find a parseable moonc version in `moon version --all`", file=sys.stderr)
    print(text, file=sys.stderr)
    raise SystemExit(2)
actual = tuple(map(int, match.groups()))
print(f"moonc {actual[0]}.{actual[1]}.{actual[2]} (minimum {minimum[0]}.{minimum[1]}.{minimum[2]})")
if actual < minimum:
    raise SystemExit(f"moonc {actual} is older than required {minimum}")
