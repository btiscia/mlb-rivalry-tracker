"""Main entry point for MLB Rivalry Tracker."""

import sys
from pathlib import Path

from .api import RivalryFetcher
from .analysis import RivalryAnalyzer
from .visualization import RivalryCharts
from .cli import parse_args, setup_logging
from .config import get_team, list_teams


def progress_callback(completed: int, total: int, year: int) -> None:
    """Print progress updates during data fetching."""
    print(f"  Fetched {year} ({completed}/{total})")


def export_csv(games_df, output_dir: Path, team1_name: str, team2_name: str, 
               start_year: int, end_year: int) -> str:
    """Export game data to CSV."""
    output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"Rivalry_Data_{team1_name}_vs_{team2_name}_{start_year}_to_{end_year}.csv"
    filepath = output_dir / filename
    games_df.to_csv(filepath, index=False)
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
    show_charts: bool = False,
) -> None:
    """
    Run the full rivalry analysis pipeline.

    Args:
        team1_code: First team code (e.g., 'nya')
        team2_code: Second team code (e.g., 'bos')
        start_year: Starting year
        end_year: Ending year
        output_dir: Directory for output files
        cache_dir: Directory for cached API responses
        use_cache: Whether to use caching
        save_csv: Whether to save CSV data
        save_png: Whether to save PNG images
        save_json: Whether to save JSON chart data
        show_charts: Whether to display charts in browser
    """
    # Get team info
    team1 = get_team(team1_code)
    team2 = get_team(team2_code)

    print(f"\nAnalyzing rivalry: {team1.name} vs {team2.name}")
    print(f"Period: {start_year} - {end_year}")
    print("-" * 50)

    # Fetch data
    print("\nFetching game data...")
    fetcher = RivalryFetcher(
        cache_dir=cache_dir,
        use_cache=use_cache,
    )
    games = fetcher.fetch_rivalry_data(
        team1, team2, start_year, end_year,
        progress_callback=progress_callback,
    )
    print(f"Found {len(games)} completed games")

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

    # Generate charts
    print("Generating visualizations...")
    charts = RivalryCharts(output_dir=output_dir)
    charts.create_all_charts(
        stats,
        save_json=save_json,
        save_png=save_png,
        show=show_charts,
    )
    print(f"Charts saved to: {output_dir}/")

    print("\nDone!")


def main() -> int:
    """Main CLI entry point."""
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
            show_charts=args.show,
        )
        return 0
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
