"""Tests for API fetcher module."""

import json
import os
import tempfile
from pathlib import Path
from typing import List
from unittest.mock import MagicMock, patch

import pytest

from rivalry_tracker.api.fetcher import GameResult, RivalryFetcher
from rivalry_tracker.config import TeamInfo


class TestGameResult:
    """Tests for GameResult dataclass."""

    def test_game_result_creation(self):
        """Should create GameResult with all fields."""
        game = GameResult(
            date='2020-07-24',
            winner='New York Yankees',
            home_team='New York Yankees',
            away_team='Boston Red Sox',
            home_score=5,
            away_score=3,
            game_id=12345,
        )

        assert game.date == '2020-07-24'
        assert game.winner == 'New York Yankees'
        assert game.home_team == 'New York Yankees'
        assert game.away_team == 'Boston Red Sox'
        assert game.home_score == 5
        assert game.away_score == 3
        assert game.game_id == 12345


class TestRivalryFetcherCaching:
    """Tests for caching functionality."""

    def test_cache_directory_created(self):
        """Cache directory should be created on init."""
        with tempfile.TemporaryDirectory() as tmpdir:
            cache_dir = os.path.join(tmpdir, 'test_cache')
            fetcher = RivalryFetcher(cache_dir=cache_dir, use_cache=True)
            
            assert os.path.exists(cache_dir)

    def test_cache_not_created_when_disabled(self):
        """Cache directory should not be created when caching disabled."""
        with tempfile.TemporaryDirectory() as tmpdir:
            cache_dir = os.path.join(tmpdir, 'no_cache_dir')
            fetcher = RivalryFetcher(cache_dir=cache_dir, use_cache=False)
            
            assert not os.path.exists(cache_dir)

    def test_cache_key_generation(self):
        """Cache keys should be consistent."""
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir)
            
            key1 = fetcher._get_cache_key(147, 111, 2020)
            key2 = fetcher._get_cache_key(147, 111, 2020)
            key3 = fetcher._get_cache_key(147, 111, 2021)
            
            assert key1 == key2  # Same inputs = same key
            assert key1 != key3  # Different year = different key

    def test_save_and_load_cache(self):
        """Should save and load from cache correctly."""
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir)
            
            test_data = [{'game_id': 1, 'winner': 'Team A'}]
            cache_key = 'test_key'
            
            fetcher._save_to_cache(cache_key, test_data)
            loaded = fetcher._load_from_cache(cache_key)
            
            assert loaded == test_data

    def test_load_missing_cache_returns_none(self):
        """Should return None for missing cache."""
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir)
            
            result = fetcher._load_from_cache('nonexistent_key')
            
            assert result is None

    def test_clear_cache(self):
        """Should clear all cached files."""
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir)
            
            # Create some cache files
            for i in range(3):
                fetcher._save_to_cache(f'key_{i}', [{'data': i}])
            
            # Verify files exist
            cache_files = list(Path(tmpdir).glob('*.json'))
            assert len(cache_files) == 3
            
            # Clear cache
            count = fetcher.clear_cache()
            
            assert count == 3
            assert len(list(Path(tmpdir).glob('*.json'))) == 0


class TestRivalryFetcherAPI:
    """Tests for API fetching functionality."""

    @patch('rivalry_tracker.api.fetcher.statsapi.schedule')
    def test_fetch_with_retry_success(
        self,
        mock_schedule: MagicMock,
        mock_api_response: List[dict],
    ):
        """Should fetch data successfully."""
        mock_schedule.return_value = mock_api_response
        
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir, use_cache=False)
            
            result = fetcher._fetch_season_with_retry(147, 111, 2020)
            
            assert result == mock_api_response
            mock_schedule.assert_called_once_with(
                team=147,
                opponent=111,
                season=2020,
            )

    @patch('rivalry_tracker.api.fetcher.statsapi.schedule')
    def test_fetch_uses_cache(
        self,
        mock_schedule: MagicMock,
        mock_api_response: List[dict],
    ):
        """Should use cached data when available."""
        mock_schedule.return_value = mock_api_response
        
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir, use_cache=True)
            
            # First call - should hit API
            result1 = fetcher._fetch_season_with_retry(147, 111, 2020)
            assert mock_schedule.call_count == 1
            
            # Second call - should use cache
            result2 = fetcher._fetch_season_with_retry(147, 111, 2020)
            assert mock_schedule.call_count == 1  # No additional API call
            
            assert result1 == result2

    @patch('rivalry_tracker.api.fetcher.statsapi.schedule')
    def test_fetch_rivalry_data_filters_final_games(
        self,
        mock_schedule: MagicMock,
        mock_api_response: List[dict],
        yankees: TeamInfo,
        red_sox: TeamInfo,
    ):
        """Should only return completed (Final) games."""
        mock_schedule.return_value = mock_api_response
        
        with tempfile.TemporaryDirectory() as tmpdir:
            fetcher = RivalryFetcher(cache_dir=tmpdir, use_cache=False)
            
            games = fetcher.fetch_rivalry_data(yankees, red_sox, 2020, 2020)
            
            # Should filter out the "Postponed" game
            assert len(games) == 2
            for game in games:
                assert isinstance(game, GameResult)
