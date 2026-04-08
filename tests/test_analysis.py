"""Tests for analysis module."""

from typing import List

import pytest

from rivalry_tracker.analysis.stats import RivalryAnalyzer, RivalryStats
from rivalry_tracker.api.fetcher import GameResult
from rivalry_tracker.config import TeamInfo


class TestRivalryAnalyzer:
    """Tests for RivalryAnalyzer class."""

    def test_analyze_basic_stats(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """Should compute correct basic statistics."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)

        assert stats.team1_name == 'New York Yankees'
        assert stats.team2_name == 'Boston Red Sox'
        assert stats.total_games == 6
        assert stats.team1_wins == 4
        assert stats.team2_wins == 2
        assert stats.winner_name == 'New York Yankees'
        assert stats.loser_name == 'Boston Red Sox'

    def test_analyze_empty_games_raises_error(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
    ):
        """Should raise ValueError for empty games list."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        
        with pytest.raises(ValueError) as exc_info:
            analyzer.analyze([], 2020, 2021)
        
        assert 'no games' in str(exc_info.value).lower()

    def test_analyze_year_range(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """Should track correct year range."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)

        assert stats.start_year == 2020
        assert stats.end_year == 2021

    def test_analyze_wins_by_year(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """Should correctly count wins by year."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)

        # 2020: Yankees 3, Red Sox 1
        # 2021: Yankees 1, Red Sox 1
        assert 2020 in stats.wins_by_year.index
        assert 2021 in stats.wins_by_year.index

    def test_color_map_assignment(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """Winner should get winner color."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)

        # Yankees have more wins, should get winner color
        assert stats.color_map['New York Yankees'] == '#00B0F0'  # WINNER_COLOR
        assert stats.color_map['Boston Red Sox'] == '#C00000'    # LOSER_COLOR

    def test_to_summary_contains_key_info(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """Summary should contain key information."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)
        summary = analyzer.to_summary(stats)

        assert 'Yankees' in summary
        assert 'Red Sox' in summary
        assert '2020' in summary
        assert '2021' in summary
        assert '4 wins' in summary
        assert '2 wins' in summary


class TestRivalryStatsDataclass:
    """Tests for RivalryStats dataclass."""

    def test_stats_has_expected_fields(
        self,
        yankees: TeamInfo,
        red_sox: TeamInfo,
        sample_games: List[GameResult],
    ):
        """RivalryStats should have all expected fields."""
        analyzer = RivalryAnalyzer(yankees, red_sox)
        stats = analyzer.analyze(sample_games, 2020, 2021)

        # Check all fields exist
        assert hasattr(stats, 'team1_name')
        assert hasattr(stats, 'team2_name')
        assert hasattr(stats, 'start_year')
        assert hasattr(stats, 'end_year')
        assert hasattr(stats, 'total_games')
        assert hasattr(stats, 'team1_wins')
        assert hasattr(stats, 'team2_wins')
        assert hasattr(stats, 'wins_by_year')
        assert hasattr(stats, 'winner_name')
        assert hasattr(stats, 'loser_name')
        assert hasattr(stats, 'color_map')
        assert hasattr(stats, 'games_df')
