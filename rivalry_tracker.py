#!/usr/bin/env python3
"""
Legacy entry point for MLB Rivalry Tracker.

This script is maintained for backward compatibility.
For new usage, prefer: python -m rivalry_tracker

Example usage:
    python rivalry_tracker.py nya bos 1995 2004
"""

import sys
import warnings

# Show deprecation notice for direct script usage
warnings.warn(
    "Direct script usage is deprecated. Use 'python -m rivalry_tracker' instead.",
    DeprecationWarning,
    stacklevel=1
)

from rivalry_tracker.main import main

if __name__ == "__main__":
    sys.exit(main())