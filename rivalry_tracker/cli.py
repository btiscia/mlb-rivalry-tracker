"""Command-line interface for MLB Rivalry Tracker."""

import argparse
import logging
import sys
from typing import Optional

from .config import (
    DEFAULT_CACHE_DIR,
    DEFAULT_OUTPUT_DIR,
    get_team,
    list_teams,
    validate_team_codes,
)


def setup_logging(verbose: bool = False) -> None:
    """Configure logging based on verbosity."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%H:%M:%S',
    )


def create_parser() -> argparse.ArgumentParser:
    """Create the argument parser."""
    parser = argparse.ArgumentParser(
        prog='rivalry-tracker',
        description='Analyze MLB team rivalries with statistics and visualizations.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m rivalry_tracker nya bos 1995 2004
  python -m rivalry_tracker sln chn 2000 2020 --output results/
  python -m rivalry_tracker --list-teams
  python -m rivalry_tracker nya bos 1990 2000 --no-cache
        """,
    )

    # Positional arguments
    parser.add_argument(
        'team1',
        nargs='?',
        help="First team code (e.g., 'nya' for Yankees)",
    )
    parser.add_argument(
        'team2',
        nargs='?',
        help="Second team code (e.g., 'bos' for Red Sox)",
    )
    parser.add_argument(
        'start_year',
        nargs='?',
        type=int,
        help='Start year (e.g., 1995)',
    )
    parser.add_argument(
        'end_year',
        nargs='?',
        type=int,
        help='End year (e.g., 2004)',
    )

    # Optional arguments
    parser.add_argument(
        '-o', '--output',
        default=DEFAULT_OUTPUT_DIR,
        help=f'Output directory (default: {DEFAULT_OUTPUT_DIR})',
    )
    parser.add_argument(
        '--cache-dir',
        default=DEFAULT_CACHE_DIR,
        help=f'Cache directory (default: {DEFAULT_CACHE_DIR})',
    )
    parser.add_argument(
        '--no-cache',
        action='store_true',
        help='Disable caching (always fetch from API)',
    )
    parser.add_argument(
        '--clear-cache',
        action='store_true',
        help='Clear the cache and exit',
    )
    parser.add_argument(
        '--no-png',
        action='store_true',
        help='Skip PNG image generation',
    )
    parser.add_argument(
        '--no-json',
        action='store_true',
        help='Skip JSON chart data generation',
    )
    parser.add_argument(
        '--no-csv',
        action='store_true',
        help='Skip CSV data export',
    )
    parser.add_argument(
        '--show',
        action='store_true',
        help='Display charts in browser after generation',
    )
    parser.add_argument(
        '-l', '--list-teams',
        action='store_true',
        help='List all available team codes and exit',
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output',
    )
    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0',
    )

    return parser


def validate_args(args: argparse.Namespace) -> Optional[str]:
    """
    Validate command-line arguments.
    
    Returns error message if invalid, None if valid.
    """
    # Check if showing teams list
    if args.list_teams or args.clear_cache:
        return None

    # Check required positional args
    required = ['team1', 'team2', 'start_year', 'end_year']
    missing = [arg for arg in required if getattr(args, arg) is None]
    
    if missing:
        return f"Missing required arguments: {', '.join(missing)}"

    # Validate team codes
    try:
        validate_team_codes(args.team1, args.team2)
    except ValueError as e:
        return str(e)

    # Validate years
    if args.start_year > args.end_year:
        return f"Start year ({args.start_year}) must be <= end year ({args.end_year})"

    if args.start_year < 1871:
        return "Start year must be 1871 or later (first MLB season)"

    return None


def parse_args(argv: Optional[list] = None) -> argparse.Namespace:
    """Parse and validate command-line arguments."""
    parser = create_parser()
    args = parser.parse_args(argv)

    error = validate_args(args)
    if error:
        parser.error(error)

    return args
