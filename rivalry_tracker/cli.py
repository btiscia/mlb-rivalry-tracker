"""Command-line interface for MLB Rivalry Tracker.

This module provides the command-line argument parsing and validation
for the MLB Rivalry Tracker application.
"""

import argparse
import logging
import sys
from typing import List, Optional

from .config import (
    DEFAULT_CACHE_DIR,
    DEFAULT_OUTPUT_DIR,
    get_team,
    list_teams,
    validate_team_codes,
)


def setup_logging(verbose: bool = False) -> None:
    """Configure logging based on verbosity level.
    
    Args:
        verbose: If True, enable DEBUG level logging.
    """
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%H:%M:%S',
    )


def create_parser() -> argparse.ArgumentParser:
    """Create the argument parser.
    
    Returns:
        Configured ArgumentParser object.
    """
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
  python -m rivalry_tracker nya bos 2000 2020 --no-excel --no-html
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

    # Output options
    output_group = parser.add_argument_group('Output Options')
    output_group.add_argument(
        '-o', '--output',
        default=DEFAULT_OUTPUT_DIR,
        help=f'Output directory (default: {DEFAULT_OUTPUT_DIR})',
    )
    output_group.add_argument(
        '--no-png',
        action='store_true',
        help='Skip PNG image generation',
    )
    output_group.add_argument(
        '--no-json',
        action='store_true',
        help='Skip JSON chart data generation',
    )
    output_group.add_argument(
        '--no-csv',
        action='store_true',
        help='Skip CSV data export',
    )
    output_group.add_argument(
        '--no-excel',
        action='store_true',
        help='Skip Excel workbook export',
    )
    output_group.add_argument(
        '--no-html',
        action='store_true',
        help='Skip HTML report generation',
    )
    output_group.add_argument(
        '--show',
        action='store_true',
        help='Display charts in browser after generation',
    )

    # Cache options
    cache_group = parser.add_argument_group('Cache Options')
    cache_group.add_argument(
        '--cache-dir',
        default=DEFAULT_CACHE_DIR,
        help=f'Cache directory (default: {DEFAULT_CACHE_DIR})',
    )
    cache_group.add_argument(
        '--no-cache',
        action='store_true',
        help='Disable caching (always fetch from API)',
    )
    cache_group.add_argument(
        '--clear-cache',
        action='store_true',
        help='Clear the cache and exit',
    )

    # Other options
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
        version='%(prog)s 1.1.0',
    )

    return parser


def validate_args(args: argparse.Namespace) -> Optional[str]:
    """Validate command-line arguments.
    
    Args:
        args: Parsed argument namespace.
    
    Returns:
        Error message string if validation fails, None if valid.
    """
    # Check if showing teams list or clearing cache
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
    
    # Reasonable upper bound for year
    import datetime
    current_year = datetime.datetime.now().year
    if args.end_year > current_year + 1:
        return f"End year cannot be more than 1 year in the future (max: {current_year + 1})"

    return None


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse and validate command-line arguments.
    
    Args:
        argv: Optional list of argument strings. If None, uses sys.argv.
        
    Returns:
        Validated argument namespace.
        
    Raises:
        SystemExit: If arguments are invalid.
    """
    parser = create_parser()
    args = parser.parse_args(argv)

    error = validate_args(args)
    if error:
        parser.error(error)

    return args
