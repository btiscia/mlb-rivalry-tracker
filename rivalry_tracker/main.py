"""Main entry point for MLB Rivalry Tracker.

This module orchestrates the full rivalry analysis pipeline, coordinating
data fetching, statistical analysis, and visualization generation.
"""

import logging
import sys
from pathlib import Path
from typing import Optional

from .api import RivalryFetcher
from .analysis import RivalryAnalyzer
from .visualization import RivalryCharts
from .cli import parse_args, setup_logging
from .config import get_team, list_teams

logger = logging.getLogger(__name__)


def progress_callback(completed: int, total: int, year: int) -> None:
    """Print progress updates during data fetching.
    
    Args:
        completed: Number of years completed.
        total: Total number of years to fetch.
        year: The year that was just fetched.
    """
    print(f"  Fetched {year} ({completed}/{total})")


def export_csv(
    games_df,
    output_dir: Path,
    team1_name: str,
    team2_name: str,
    start_year: int,
    end_year: int
) -> str:
    """Export game data to CSV.
    
    Args:
        games_df: DataFrame containing game data.
        output_dir: Directory for output files.
        team1_name: Name of the first team.
        team2_name: Name of the second team.
        start_year: First year of the analysis period.
        end_year: Last year of the analysis period.
        
    Returns:
        Path to the created CSV file.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"Rivalry_Data_{team1_name}_vs_{team2_name}_{start_year}_to_{end_year}.csv"
    filepath = output_dir / filename
    
    # Format date column for CSV
    df_copy = games_df.copy()
    df_copy['date'] = df_copy['date'].dt.strftime('%Y-%m-%d')
    df_copy.to_csv(filepath, index=False)
    
    return str(filepath)


def run(
    team1_code: str,
    team2_code: str,
    start_year: int,
    end_year: int,
    output_dir: str = 'output',
    cache_dir: str = '.cache',
    use_cache: bool = True,
    save_csv: bool = True,
    save_png: bool = True,
    save_json: bool = True,
    save_excel: bool = True,
    save_html: bool = True,
    show_charts: bool = False,
    show_progress: bool = True,
) -> None:
    """Run the full rivalry analysis pipeline.

    Args:
        team1_code: First team code (e.g., 'nya').
        team2_code: Second team code (e.g., 'bos').
        start_year: Starting year for analysis.
        end_year: Ending year for analysis.
        output_dir: Directory for output files.
        cache_dir: Directory for cached API responses.
        use_cache: Whether to use response caching.
        save_csv: Whether to save CSV data export.
        save_png: Whether to save PNG chart images.
        save_json: Whether to save JSON chart data.
        save_excel: Whether to save Excel workbook.
        save_html: Whether to save HTML report.
        show_charts: Whether to display charts in browser.
        show_progress: Whether to show progress bar during fetch.
        
    Raises:
        ValueError: If team codes are invalid or no games are found.
    """
    # Get team info
    team1 = get_team(team1_code)
    team2 = get_team(team2_code)
    
    if not team1:
        raise ValueError(f"Invalid team code: '{team1_code}'")
    if not team2:
        raise ValueError(f"Invalid team code: '{team2_code}'")

    print(f"\nAnalyzing rivalry: {team1.name} vs {team2.name}")
    print(f"Period: {start_year} - {end_year}")
    print("-" * 50)

    # Fetch data
    print("\nFetching game data...")
    fetcher = RivalryFetcher(
        cache_dir=cache_dir,
        use_cache=use_cache,
    )
    
    # Use tqdm if available, otherwise use callback
    games = fetcher.fetch_rivalry_data(
        team1, team2, start_year, end_year,
        progress_callback=None if show_progress else progress_callback,
        show_progress=show_progress,
    )
    print(f"Found {len(games)} completed games")
    
    if not games:
        raise ValueError(
            f"No games found between {team1.name} and {team2.name} "
            f"from {start_year} to {end_year}. "
            "Please verify the team codes and year range."
        )

    # Analyze
    print("\nAnalyzing results...")
    analyzer = RivalryAnalyzer(team1, team2)
    stats = analyzer.analyze(games, start_year, end_year)
    print(analyzer.to_summary(stats))

    # Export CSV
    if save_csv:
        csv_path = export_csv(
            stats.games_df, 
            Path(output_dir),
            team1.name, 
            team2.name, 
            start_year, 
            end_year
        )
        print(f"CSV exported: {csv_path}")

    # Generate charts and exports
    print("Generating visualizations...")
    charts = RivalryCharts(output_dir=output_dir)
    results = charts.create_all_charts(
        stats,
        save_json=save_json,
        save_png=save_png,
        save_excel=save_excel,
        save_html=save_html,
        show=show_charts,
    )
    
    print(f"Charts saved to: {output_dir}/")
    
    if save_excel and results.get('files'):
        for f in results['files']:
            if f.endswith('.xlsx'):
                print(f"Excel exported: {f}")
    
    if save_html and results.get('files'):
        for f in results['files']:
            if f.endswith('.html'):
                print(f"HTML report: {f}")

    print("\nDone!")


def main() -> int:
    """Main CLI entry point.
    
    Returns:
        Exit code (0 for success, non-zero for errors).
    """
    args = parse_args()
    setup_logging(args.verbose)

    # Handle special commands
    if args.list_teams:
        list_teams()
        return 0

    if args.clear_cache:
        fetcher = RivalryFetcher(cache_dir=args.cache_dir)
        count = fetcher.clear_cache()
        print(f"Cleared {count} cached files")
        return 0

    # Run analysis
    try:
        run(
            team1_code=args.team1.lower(),
            team2_code=args.team2.lower(),
            start_year=args.start_year,
            end_year=args.end_year,
            output_dir=args.output,
            cache_dir=args.cache_dir,
            use_cache=not args.no_cache,
            save_csv=not args.no_csv,
            save_png=not args.no_png,
            save_json=not args.no_json,
            save_excel=not getattr(args, 'no_excel', False),
            save_html=not getattr(args, 'no_html', False),
            show_charts=args.show,
        )
        return 0
        
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
        
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.", file=sys.stderr)
        return 130
        
    except Exception as e:
        logger.exception("Unexpected error occurred")
        print(f"Unexpected error: {e}", file=sys.stderr)
        print("Please check your internet connection and try again.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
