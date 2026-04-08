"""Statistical analysis for rivalry data.

This module provides comprehensive statistical analysis of MLB rivalry data,
including win/loss records, home/away splits, win streaks, and run differentials.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

import pandas as pd

from ..api.fetcher import GameResult
from ..config import LOSER_COLOR, TeamInfo, WINNER_COLOR


@dataclass
class HomeAwaySplit:
    """Home/away performance split for a team."""

    team_name: str
    home_wins: int
    home_losses: int
    away_wins: int
    away_losses: int

    @property
    def home_win_pct(self) -> float:
        """Calculate home winning percentage."""
        total = self.home_wins + self.home_losses
        return self.home_wins / total if total > 0 else 0.0

    @property
    def away_win_pct(self) -> float:
        """Calculate away winning percentage."""
        total = self.away_wins + self.away_losses
        return self.away_wins / total if total > 0 else 0.0

    @property
    def total_wins(self) -> int:
        """Total wins (home + away)."""
        return self.home_wins + self.away_wins

    @property
    def total_losses(self) -> int:
        """Total losses (home + away)."""
        return self.home_losses + self.away_losses


@dataclass
class WinStreak:
    """Information about a win streak."""

    team_name: str
    length: int
    start_date: str
    end_date: str


@dataclass
class RunDifferential:
    """Run differential statistics for a team."""

    team_name: str
    runs_scored: int
    runs_allowed: int
    total_games: int

    @property
    def differential(self) -> int:
        """Net run differential."""
        return self.runs_scored - self.runs_allowed

    @property
    def avg_runs_scored(self) -> float:
        """Average runs scored per game."""
        return self.runs_scored / self.total_games if self.total_games > 0 else 0.0

    @property
    def avg_runs_allowed(self) -> float:
        """Average runs allowed per game."""
        return self.runs_allowed / self.total_games if self.total_games > 0 else 0.0


@dataclass
class RivalryStats:
    """Aggregated rivalry statistics.
    
    Attributes:
        team1_name: Name of the first team.
        team2_name: Name of the second team.
        start_year: First year of the analysis period.
        end_year: Last year of the analysis period.
        total_games: Total number of games played.
        team1_wins: Number of wins by team 1.
        team2_wins: Number of wins by team 2.
        wins_by_year: DataFrame with wins by year and team.
        winner_name: Name of the team with more wins.
        loser_name: Name of the team with fewer wins.
        color_map: Mapping of team names to chart colors.
        games_df: DataFrame with all game data.
        home_away_splits: Home/away performance for each team.
        longest_win_streaks: Longest win streak for each team.
        run_differentials: Run differential stats for each team.
    """

    team1_name: str
    team2_name: str
    start_year: int
    end_year: int
    total_games: int
    team1_wins: int
    team2_wins: int
    wins_by_year: pd.DataFrame
    winner_name: str
    loser_name: str
    color_map: Dict[str, str]
    games_df: pd.DataFrame
    home_away_splits: Dict[str, HomeAwaySplit] = field(default_factory=dict)
    longest_win_streaks: Dict[str, WinStreak] = field(default_factory=dict)
    run_differentials: Dict[str, RunDifferential] = field(default_factory=dict)


class RivalryAnalyzer:
    """Analyzes rivalry game data and computes statistics.
    
    This class takes raw game data and computes various statistics including
    overall win/loss records, home/away splits, win streaks, and run differentials.
    
    Attributes:
        team1: First team info.
        team2: Second team info.
    
    Example:
        >>> from rivalry_tracker.config import get_team
        >>> yankees = get_team('nya')
        >>> red_sox = get_team('bos')
        >>> analyzer = RivalryAnalyzer(yankees, red_sox)
        >>> stats = analyzer.analyze(games, 2020, 2023)
        >>> print(analyzer.to_summary(stats))
    """

    def __init__(self, team1: TeamInfo, team2: TeamInfo) -> None:
        """Initialize the analyzer.
        
        Args:
            team1: First team info object.
            team2: Second team info object.
        """
        self.team1 = team1
        self.team2 = team2

    def _compute_home_away_splits(
        self, df: pd.DataFrame
    ) -> Dict[str, HomeAwaySplit]:
        """Compute home/away win-loss splits for each team.
        
        Args:
            df: DataFrame with game data including home_team, away_team, winner columns.
            
        Returns:
            Dictionary mapping team names to their HomeAwaySplit data.
        """
        splits: Dict[str, HomeAwaySplit] = {}
        
        for team_name in [self.team1.name, self.team2.name]:
            # Games where this team was home
            home_games = df[df['home_team'] == team_name]
            home_wins = len(home_games[home_games['winner'] == team_name])
            home_losses = len(home_games) - home_wins
            
            # Games where this team was away
            away_games = df[df['away_team'] == team_name]
            away_wins = len(away_games[away_games['winner'] == team_name])
            away_losses = len(away_games) - away_wins
            
            splits[team_name] = HomeAwaySplit(
                team_name=team_name,
                home_wins=home_wins,
                home_losses=home_losses,
                away_wins=away_wins,
                away_losses=away_losses,
            )
        
        return splits

    def _compute_longest_win_streaks(
        self, df: pd.DataFrame
    ) -> Dict[str, WinStreak]:
        """Find the longest win streak for each team.
        
        Args:
            df: DataFrame with game data sorted by date.
            
        Returns:
            Dictionary mapping team names to their longest WinStreak.
        """
        streaks: Dict[str, WinStreak] = {}
        df_sorted = df.sort_values('date').reset_index(drop=True)
        
        for team_name in [self.team1.name, self.team2.name]:
            max_streak = 0
            current_streak = 0
            streak_start: Optional[str] = None
            best_start: Optional[str] = None
            best_end: Optional[str] = None
            
            for _, row in df_sorted.iterrows():
                if row['winner'] == team_name:
                    if current_streak == 0:
                        streak_start = str(row['date'])[:10]
                    current_streak += 1
                    
                    if current_streak > max_streak:
                        max_streak = current_streak
                        best_start = streak_start
                        best_end = str(row['date'])[:10]
                else:
                    current_streak = 0
                    streak_start = None
            
            streaks[team_name] = WinStreak(
                team_name=team_name,
                length=max_streak,
                start_date=best_start or '',
                end_date=best_end or '',
            )
        
        return streaks

    def _compute_run_differentials(
        self, df: pd.DataFrame
    ) -> Dict[str, RunDifferential]:
        """Compute run differential statistics for each team.
        
        Args:
            df: DataFrame with game data including home_team, away_team, 
                home_score, away_score columns.
                
        Returns:
            Dictionary mapping team names to their RunDifferential data.
        """
        differentials: Dict[str, RunDifferential] = {}
        
        for team_name in [self.team1.name, self.team2.name]:
            runs_scored = 0
            runs_allowed = 0
            games_played = 0
            
            for _, row in df.iterrows():
                if row['home_team'] == team_name:
                    runs_scored += row['home_score']
                    runs_allowed += row['away_score']
                    games_played += 1
                elif row['away_team'] == team_name:
                    runs_scored += row['away_score']
                    runs_allowed += row['home_score']
                    games_played += 1
            
            differentials[team_name] = RunDifferential(
                team_name=team_name,
                runs_scored=runs_scored,
                runs_allowed=runs_allowed,
                total_games=games_played,
            )
        
        return differentials

    def analyze(
        self,
        games: List[GameResult],
        start_year: int,
        end_year: int,
    ) -> RivalryStats:
        """Analyze game results and compute rivalry statistics.

        Args:
            games: List of game results to analyze.
            start_year: Starting year of analysis period.
            end_year: Ending year of analysis period.

        Returns:
            RivalryStats object containing all computed statistics.

        Raises:
            ValueError: If the games list is empty.
        """
        if not games:
            raise ValueError("No games found in the specified date range.")

        # Convert to DataFrame
        df = pd.DataFrame([
            {
                'date': g.date,
                'winner': g.winner,
                'home_team': g.home_team,
                'away_team': g.away_team,
                'home_score': g.home_score,
                'away_score': g.away_score,
            }
            for g in games
        ])

        df['date'] = pd.to_datetime(df['date'])
        df['year'] = df['date'].dt.year

        # Count wins by team and year
        wins_by_year = df.groupby(['year', 'winner']).size().unstack(fill_value=0)

        # Total wins
        total_wins = df['winner'].value_counts()
        
        if len(total_wins) < 2:
            # Only one team has wins - still valid but need to handle
            teams = [self.team1.name, self.team2.name]
            for team in teams:
                if team not in total_wins.index:
                    total_wins[team] = 0

        winner_name = total_wins.idxmax()
        loser_name = total_wins.idxmin()

        # Dynamic color mapping based on wins
        color_map = {
            winner_name: WINNER_COLOR,
            loser_name: LOSER_COLOR,
        }

        # Compute advanced statistics
        home_away_splits = self._compute_home_away_splits(df)
        longest_win_streaks = self._compute_longest_win_streaks(df)
        run_differentials = self._compute_run_differentials(df)

        return RivalryStats(
            team1_name=self.team1.name,
            team2_name=self.team2.name,
            start_year=start_year,
            end_year=end_year,
            total_games=len(df),
            team1_wins=int(total_wins.get(self.team1.name, 0)),
            team2_wins=int(total_wins.get(self.team2.name, 0)),
            wins_by_year=wins_by_year,
            winner_name=winner_name,
            loser_name=loser_name,
            color_map=color_map,
            games_df=df,
            home_away_splits=home_away_splits,
            longest_win_streaks=longest_win_streaks,
            run_differentials=run_differentials,
        )

    def to_summary(self, stats: RivalryStats) -> str:
        """Generate a text summary of the rivalry stats.
        
        Args:
            stats: RivalryStats object to summarize.
            
        Returns:
            Formatted string summary of the rivalry.
        """
        team1_split = stats.home_away_splits.get(stats.team1_name)
        team2_split = stats.home_away_splits.get(stats.team2_name)
        team1_streak = stats.longest_win_streaks.get(stats.team1_name)
        team2_streak = stats.longest_win_streaks.get(stats.team2_name)
        team1_runs = stats.run_differentials.get(stats.team1_name)
        team2_runs = stats.run_differentials.get(stats.team2_name)

        lines = [
            f"\n{'='*60}",
            f"Rivalry Summary: {stats.team1_name} vs {stats.team2_name}",
            f"{'='*60}",
            f"Period: {stats.start_year} - {stats.end_year}",
            f"Total Games: {stats.total_games}",
            f"",
            f"Overall Record:",
            f"  {stats.team1_name}: {stats.team1_wins} wins",
            f"  {stats.team2_name}: {stats.team2_wins} wins",
            f"",
        ]
        
        if team1_split and team2_split:
            lines.extend([
                f"Home/Away Splits:",
                f"  {stats.team1_name}:",
                f"    Home: {team1_split.home_wins}-{team1_split.home_losses} ({team1_split.home_win_pct:.3f})",
                f"    Away: {team1_split.away_wins}-{team1_split.away_losses} ({team1_split.away_win_pct:.3f})",
                f"  {stats.team2_name}:",
                f"    Home: {team2_split.home_wins}-{team2_split.home_losses} ({team2_split.home_win_pct:.3f})",
                f"    Away: {team2_split.away_wins}-{team2_split.away_losses} ({team2_split.away_win_pct:.3f})",
                f"",
            ])
        
        if team1_streak and team2_streak:
            lines.extend([
                f"Longest Win Streaks:",
                f"  {stats.team1_name}: {team1_streak.length} games",
            ])
            if team1_streak.start_date:
                lines.append(f"    ({team1_streak.start_date} to {team1_streak.end_date})")
            lines.append(f"  {stats.team2_name}: {team2_streak.length} games")
            if team2_streak.start_date:
                lines.append(f"    ({team2_streak.start_date} to {team2_streak.end_date})")
            lines.append("")
        
        if team1_runs and team2_runs:
            lines.extend([
                f"Run Differential:",
                f"  {stats.team1_name}: {team1_runs.differential:+d} ({team1_runs.avg_runs_scored:.2f} RS, {team1_runs.avg_runs_allowed:.2f} RA)",
                f"  {stats.team2_name}: {team2_runs.differential:+d} ({team2_runs.avg_runs_scored:.2f} RS, {team2_runs.avg_runs_allowed:.2f} RA)",
                f"",
            ])

        lines.extend([
            f"Overall Leader: {stats.winner_name}",
            f"{'='*60}\n",
        ])
        
        return "\n".join(lines)
