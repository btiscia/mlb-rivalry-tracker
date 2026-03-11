"""API fetcher with caching, parallel requests, and retry logic."""

import hashlib
import json
import logging
import os
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional

import statsapi

from ..config import (
    API_RETRY_ATTEMPTS,
    API_RETRY_DELAY,
    DEFAULT_CACHE_DIR,
    MAX_API_WORKERS,
    TeamInfo,
)

logger = logging.getLogger(__name__)


@dataclass
class GameResult:
    """Represents a single game result."""
    date: str
    winner: str
    home_team: str
    away_team: str
    home_score: int
    away_score: int
    game_id: int


class RivalryFetcher:
    """Fetches rivalry data from MLB Stats API with caching and parallel requests."""

    def __init__(
        self,
        cache_dir: str = DEFAULT_CACHE_DIR,
        max_workers: int = MAX_API_WORKERS,
        use_cache: bool = True,
    ):
        self.cache_dir = Path(cache_dir)
        self.max_workers = max_workers
        self.use_cache = use_cache

        if self.use_cache:
            self.cache_dir.mkdir(parents=True, exist_ok=True)

    def _get_cache_key(self, team1_id: int, team2_id: int, year: int) -> str:
        """Generate a unique cache key for a query."""
        key = f"{team1_id}_{team2_id}_{year}"
        return hashlib.md5(key.encode()).hexdigest()

    def _get_cache_path(self, cache_key: str) -> Path:
        """Get the cache file path for a given key."""
        return self.cache_dir / f"{cache_key}.json"

    def _load_from_cache(self, cache_key: str) -> Optional[List[Dict[str, Any]]]:
        """Load data from cache if available."""
        if not self.use_cache:
            return None

        cache_path = self._get_cache_path(cache_key)
        if cache_path.exists():
            try:
                with open(cache_path, 'r') as f:
                    logger.debug(f"Cache hit: {cache_key}")
                    return json.load(f)
            except (json.JSONDecodeError, IOError) as e:
                logger.warning(f"Cache read error: {e}")
                return None
        return None

    def _save_to_cache(self, cache_key: str, data: List[Dict[str, Any]]) -> None:
        """Save data to cache."""
        if not self.use_cache:
            return

        cache_path = self._get_cache_path(cache_key)
        try:
            with open(cache_path, 'w') as f:
                json.dump(data, f)
            logger.debug(f"Cached: {cache_key}")
        except IOError as e:
            logger.warning(f"Cache write error: {e}")

    def _fetch_season_with_retry(
        self,
        team1_id: int,
        team2_id: int,
        year: int,
        retries: int = API_RETRY_ATTEMPTS,
    ) -> List[Dict[str, Any]]:
        """Fetch a single season's data with retry logic."""
        cache_key = self._get_cache_key(team1_id, team2_id, year)
        
        # Try cache first
        cached = self._load_from_cache(cache_key)
        if cached is not None:
            return cached

        # Fetch from API with retries
        last_error = None
        for attempt in range(retries):
            try:
                logger.info(f"Fetching {year} (attempt {attempt + 1}/{retries})")
                schedule = statsapi.schedule(
                    team=team1_id,
                    opponent=team2_id,
                    season=year
                )
                
                # Cache the result
                self._save_to_cache(cache_key, schedule)
                return schedule

            except Exception as e:
                last_error = e
                logger.warning(f"API error for {year}: {e}")
                if attempt < retries - 1:
                    delay = API_RETRY_DELAY * (2 ** attempt)  # Exponential backoff
                    logger.info(f"Retrying in {delay:.1f}s...")
                    time.sleep(delay)

        logger.error(f"Failed to fetch {year} after {retries} attempts")
        raise RuntimeError(f"API request failed for {year}: {last_error}")

    def fetch_rivalry_data(
        self,
        team1: TeamInfo,
        team2: TeamInfo,
        start_year: int,
        end_year: int,
        progress_callback: Optional[callable] = None,
    ) -> List[GameResult]:
        """
        Fetch all rivalry games between two teams in parallel.

        Args:
            team1: First team info
            team2: Second team info
            start_year: Starting year (inclusive)
            end_year: Ending year (inclusive)
            progress_callback: Optional callback for progress updates

        Returns:
            List of GameResult objects for completed games
        """
        years = list(range(start_year, end_year + 1))
        all_games: List[GameResult] = []
        completed = 0
        total = len(years)

        def fetch_year(year: int) -> List[Dict[str, Any]]:
            return self._fetch_season_with_retry(team1.id, team2.id, year)

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_year = {
                executor.submit(fetch_year, year): year 
                for year in years
            }

            for future in as_completed(future_to_year):
                year = future_to_year[future]
                completed += 1
                
                try:
                    schedule = future.result()
                    
                    for game in schedule:
                        if game.get('status') == 'Final':
                            all_games.append(GameResult(
                                date=game['game_date'],
                                winner=game.get('winning_team', 'Unknown'),
                                home_team=game.get('home_name', ''),
                                away_team=game.get('away_name', ''),
                                home_score=game.get('home_score', 0),
                                away_score=game.get('away_score', 0),
                                game_id=game.get('game_id', 0),
                            ))
                    
                    if progress_callback:
                        progress_callback(completed, total, year)

                except Exception as e:
                    logger.error(f"Error fetching {year}: {e}")
                    # Continue with other years even if one fails

        # Sort by date
        all_games.sort(key=lambda g: g.date)
        return all_games

    def clear_cache(self) -> int:
        """Clear all cached data. Returns number of files deleted."""
        if not self.cache_dir.exists():
            return 0

        count = 0
        for cache_file in self.cache_dir.glob("*.json"):
            try:
                cache_file.unlink()
                count += 1
            except IOError as e:
                logger.warning(f"Failed to delete {cache_file}: {e}")
        
        return count
