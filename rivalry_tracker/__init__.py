"""MLB Rivalry Tracker - Analyze head-to-head matchups between MLB teams.

This package provides tools for fetching, analyzing, and visualizing
MLB rivalry data between any two teams over a custom year range.

Example:
    >>> from rivalry_tracker.config import get_team
    >>> from rivalry_tracker.api import RivalryFetcher
    >>> from rivalry_tracker.analysis import RivalryAnalyzer
    >>> 
    >>> yankees = get_team('nya')
    >>> red_sox = get_team('bos')
    >>> 
    >>> fetcher = RivalryFetcher()
    >>> games = fetcher.fetch_rivalry_data(yankees, red_sox, 2020, 2023)
    >>> 
    >>> analyzer = RivalryAnalyzer(yankees, red_sox)
    >>> stats = analyzer.analyze(games, 2020, 2023)
    >>> print(analyzer.to_summary(stats))
"""

__version__ = "1.1.0"
__author__ = "btiscia"

from .config import TeamInfo, get_team, list_teams, validate_team_codes
from .api import RivalryFetcher
from .api.fetcher import GameResult
from .analysis import RivalryAnalyzer
from .analysis.stats import RivalryStats, HomeAwaySplit, WinStreak, RunDifferential
from .visualization import RivalryCharts
from .main import run

__all__ = [
    # Version
    "__version__",
    # Config
    "TeamInfo",
    "get_team",
    "list_teams",
    "validate_team_codes",
    # API
    "RivalryFetcher",
    "GameResult",
    # Analysis
    "RivalryAnalyzer",
    "RivalryStats",
    "HomeAwaySplit",
    "WinStreak",
    "RunDifferential",
    # Visualization
    "RivalryCharts",
    # Main
    "run",
]
