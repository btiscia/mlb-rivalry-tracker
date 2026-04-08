"""Pytest configuration and shared fixtures."""

from datetime import date
from typing import List

import pandas as pd
import pytest

from rivalry_tracker.api.fetcher import GameResult
from rivalry_tracker.config import TeamInfo


@pytest.fixture
def yankees() -> TeamInfo:
    """New York Yankees team info."""
    return TeamInfo(id=147, color='#132448', name='New York Yankees')


@pytest.fixture
def red_sox() -> TeamInfo:
    """Boston Red Sox team info."""
    return TeamInfo(id=111, color='#BD3039', name='Boston Red Sox')


@pytest.fixture
def sample_games(yankees: TeamInfo, red_sox: TeamInfo) -> List[GameResult]:
    """Sample game results for testing."""
    return [
        GameResult(
            date='2020-07-24',
            winner='New York Yankees',
            home_team='New York Yankees',
            away_team='Boston Red Sox',
            home_score=5,
            away_score=3,
            game_id=1001,
        ),
        GameResult(
            date='2020-07-25',
            winner='Boston Red Sox',
            home_team='New York Yankees',
            away_team='Boston Red Sox',
            home_score=2,
            away_score=4,
            game_id=1002,
        ),
        GameResult(
            date='2020-08-01',
            winner='New York Yankees',
            home_team='Boston Red Sox',
            away_team='New York Yankees',
            home_score=3,
            away_score=7,
            game_id=1003,
        ),
        GameResult(
            date='2020-08-02',
            winner='New York Yankees',
            home_team='Boston Red Sox',
            away_team='New York Yankees',
            home_score=1,
            away_score=2,
            game_id=1004,
        ),
        GameResult(
            date='2021-04-10',
            winner='Boston Red Sox',
            home_team='New York Yankees',
            away_team='Boston Red Sox',
            home_score=4,
            away_score=6,
            game_id=2001,
        ),
        GameResult(
            date='2021-04-11',
            winner='New York Yankees',
            home_team='New York Yankees',
            away_team='Boston Red Sox',
            home_score=8,
            away_score=2,
            game_id=2002,
        ),
    ]


@pytest.fixture
def mock_api_response() -> List[dict]:
    """Mock API response for a single season."""
    return [
        {
            'game_id': 1001,
            'game_date': '2020-07-24',
            'status': 'Final',
            'winning_team': 'New York Yankees',
            'home_name': 'New York Yankees',
            'away_name': 'Boston Red Sox',
            'home_score': 5,
            'away_score': 3,
        },
        {
            'game_id': 1002,
            'game_date': '2020-07-25',
            'status': 'Final',
            'winning_team': 'Boston Red Sox',
            'home_name': 'New York Yankees',
            'away_name': 'Boston Red Sox',
            'home_score': 2,
            'away_score': 4,
        },
        {
            'game_id': 1003,
            'game_date': '2020-07-26',
            'status': 'Postponed',  # Should be filtered out
            'home_name': 'New York Yankees',
            'away_name': 'Boston Red Sox',
        },
    ]
