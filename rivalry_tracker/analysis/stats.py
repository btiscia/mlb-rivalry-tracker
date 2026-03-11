"""Statistical analysis for rivalry data."""

from dataclasses import dataclass
from typing import Dict, List, Tuple

import pandas as pd

from ..api.fetcher import GameResult
from ..config import LOSER_COLOR, TeamInfo, WINNER_COLOR


@dataclass
class RivalryStats:
    """Aggregated rivalry statistics."""
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


class RivalryAnalyzer:
    """Analyzes rivalry game data and computes statistics."""

    def __init__(self, team1: TeamInfo, team2: TeamInfo):
        self.team1 = team1
        self.team2 = team2

    def analyze(
        self,
        games: List[GameResult],
        start_year: int,
        end_year: int,
    ) -> RivalryStats:
        """
        Analyze game results and compute rivalry statistics.

        Args:
            games: List of game results
            start_year: Starting year of analysis
            end_year: Ending year of analysis

        Returns:
            RivalryStats with computed statistics
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
        )

    def to_summary(self, stats: RivalryStats) -> str:
        """Generate a text summary of the rivalry stats."""
        lines = [
            f"\n{'='*50}",
            f"Rivalry Summary: {stats.team1_name} vs {stats.team2_name}",
            f"{'='*50}",
            f"Period: {stats.start_year} - {stats.end_year}",
            f"Total Games: {stats.total_games}",
            f"",
            f"  {stats.team1_name}: {stats.team1_wins} wins",
            f"  {stats.team2_name}: {stats.team2_wins} wins",
            f"",
            f"Overall Leader: {stats.winner_name}",
            f"{'='*50}\n",
        ]
        return "\n".join(lines)
