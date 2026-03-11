"""Chart generation for rivalry visualizations."""

import logging
from pathlib import Path
from typing import Optional

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for saving files
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go

from ..analysis.stats import RivalryStats
from ..config import DEFAULT_OUTPUT_DIR

logger = logging.getLogger(__name__)


class RivalryCharts:
    """Generates visualizations for rivalry data."""

    def __init__(self, output_dir: str = DEFAULT_OUTPUT_DIR):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def _save_line_chart_png(self, stats: RivalryStats, filepath: Path) -> None:
        """Create line chart PNG using matplotlib."""
        plt.figure(figsize=(12, 6))
        
        for team in stats.wins_by_year.columns:
            color = stats.color_map.get(team, '#333333')
            plt.plot(stats.wins_by_year.index, stats.wins_by_year[team], 
                    marker='o', label=team, color=color, linewidth=2)
        
        plt.title(f'Rivalry Wins Per Year: {stats.team1_name} vs {stats.team2_name} ({stats.start_year}–{stats.end_year})')
        plt.xlabel('Year')
        plt.ylabel('Number of Wins')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig(filepath, dpi=150)
        plt.close()

    def _save_bar_chart_png(self, stats: RivalryStats, filepath: Path) -> None:
        """Create bar chart PNG using matplotlib."""
        plt.figure(figsize=(8, 6))
        
        teams = [stats.team1_name, stats.team2_name]
        wins = [stats.team1_wins, stats.team2_wins]
        colors = [stats.color_map.get(t, '#333333') for t in teams]
        
        plt.bar(teams, wins, color=colors)
        plt.title(f'Total Wins: {stats.team1_name} vs {stats.team2_name} ({stats.start_year}–{stats.end_year})')
        plt.xlabel('Team')
        plt.ylabel('Number of Wins')
        plt.tight_layout()
        plt.savefig(filepath, dpi=150)
        plt.close()

    def _get_file_prefix(self, stats: RivalryStats) -> str:
        """Generate a file name prefix for outputs."""
        return f"Rivalry_{stats.team1_name}_vs_{stats.team2_name}_{stats.start_year}_to_{stats.end_year}"

    def create_line_chart(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> go.Figure:
        """
        Create a line chart showing wins per year.

        Args:
            stats: Rivalry statistics
            save_json: Whether to save as JSON
            save_png: Whether to save as PNG
            show: Whether to display the chart

        Returns:
            Plotly Figure object
        """
        fig = px.line(
            stats.wins_by_year,
            markers=True,
            title=f'Rivalry Wins Per Year: {stats.team1_name} vs {stats.team2_name} ({stats.start_year}–{stats.end_year})',
            labels={'value': 'Number of Wins', 'year': 'Year'},
            color_discrete_map=stats.color_map,
        )

        fig.update_layout(
            xaxis_title="Year",
            yaxis_title="Number of Wins",
            legend_title="Team",
            hovermode="x unified",
        )

        # Save outputs
        prefix = self._get_file_prefix(stats)
        if save_json:
            fig.write_json(self.output_dir / f"{prefix}_Line.json")
        if save_png:
            self._save_line_chart_png(stats, self.output_dir / f"{prefix}_Line.png")
        if show:
            fig.show()

        return fig

    def create_bar_chart(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> go.Figure:
        """
        Create a bar chart showing total wins.

        Args:
            stats: Rivalry statistics
            save_json: Whether to save as JSON
            save_png: Whether to save as PNG
            show: Whether to display the chart

        Returns:
            Plotly Figure object
        """
        bar_data = [
            {'Team': stats.team1_name, 'Wins': stats.team1_wins},
            {'Team': stats.team2_name, 'Wins': stats.team2_wins},
        ]

        fig = px.bar(
            bar_data,
            x='Team',
            y='Wins',
            color='Team',
            title=f'Total Wins: {stats.team1_name} vs {stats.team2_name} ({stats.start_year}–{stats.end_year})',
            labels={'Team': 'Team', 'Wins': 'Number of Wins'},
            color_discrete_map=stats.color_map,
        )

        fig.update_layout(showlegend=False)

        # Save outputs
        prefix = self._get_file_prefix(stats)
        if save_json:
            fig.write_json(self.output_dir / f"{prefix}_Bar.json")
        if save_png:
            self._save_bar_chart_png(stats, self.output_dir / f"{prefix}_Bar.png")
        if show:
            fig.show()

        return fig

    def create_all_charts(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> dict:
        """
        Create all visualizations.

        Args:
            stats: Rivalry statistics
            save_json: Whether to save as JSON
            save_png: Whether to save as PNG
            show: Whether to display the charts

        Returns:
            Dictionary of figure names to Figure objects
        """
        return {
            'line': self.create_line_chart(stats, save_json, save_png, show),
            'bar': self.create_bar_chart(stats, save_json, save_png, show),
        }
