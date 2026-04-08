"""Chart generation for rivalry visualizations.

This module provides visualization capabilities for rivalry data including
line charts, bar charts, and exports to various formats (PNG, JSON, Excel, HTML).
"""

import logging
from pathlib import Path
from typing import Any, Dict, Optional

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for saving files
import matplotlib.pyplot as plt
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

from ..analysis.stats import RivalryStats
from ..config import DEFAULT_OUTPUT_DIR

logger = logging.getLogger(__name__)


# HTML report template
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1, h2 { color: #333; }
        .header {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label { color: #666; margin-top: 5px; }
        .chart-container { margin-bottom: 30px; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th { background-color: #667eea; color: white; }
        tr:hover { background-color: #f5f5f5; }
        .winner { color: #00B0F0; font-weight: bold; }
        .loser { color: #C00000; }
        footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ team1_name }} vs {{ team2_name }}</h1>
        <p>Rivalry Analysis: {{ start_year }} - {{ end_year }}</p>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-value">{{ total_games }}</div>
            <div class="stat-label">Total Games</div>
        </div>
        <div class="stat-card">
            <div class="stat-value {{ 'winner' if team1_wins > team2_wins else 'loser' }}">{{ team1_wins }}</div>
            <div class="stat-label">{{ team1_name }} Wins</div>
        </div>
        <div class="stat-card">
            <div class="stat-value {{ 'winner' if team2_wins > team1_wins else 'loser' }}">{{ team2_wins }}</div>
            <div class="stat-label">{{ team2_name }} Wins</div>
        </div>
        <div class="stat-card">
            <div class="stat-value winner">{{ winner_name }}</div>
            <div class="stat-label">Overall Leader</div>
        </div>
    </div>

    <div class="card">
        <h2>Wins Per Year</h2>
        <div id="line-chart" class="chart-container"></div>
    </div>

    <div class="card">
        <h2>Total Wins Comparison</h2>
        <div id="bar-chart" class="chart-container"></div>
    </div>

    {% if home_away_data %}
    <div class="card">
        <h2>Home/Away Splits</h2>
        <table>
            <tr>
                <th>Team</th>
                <th>Home Record</th>
                <th>Home Win %</th>
                <th>Away Record</th>
                <th>Away Win %</th>
            </tr>
            {% for split in home_away_data %}
            <tr>
                <td>{{ split.team_name }}</td>
                <td>{{ split.home_wins }}-{{ split.home_losses }}</td>
                <td>{{ "%.3f"|format(split.home_win_pct) }}</td>
                <td>{{ split.away_wins }}-{{ split.away_losses }}</td>
                <td>{{ "%.3f"|format(split.away_win_pct) }}</td>
            </tr>
            {% endfor %}
        </table>
    </div>
    {% endif %}

    {% if streak_data %}
    <div class="card">
        <h2>Longest Win Streaks</h2>
        <table>
            <tr>
                <th>Team</th>
                <th>Streak Length</th>
                <th>Period</th>
            </tr>
            {% for streak in streak_data %}
            <tr>
                <td>{{ streak.team_name }}</td>
                <td>{{ streak.length }} games</td>
                <td>{% if streak.start_date %}{{ streak.start_date }} to {{ streak.end_date }}{% else %}N/A{% endif %}</td>
            </tr>
            {% endfor %}
        </table>
    </div>
    {% endif %}

    {% if run_diff_data %}
    <div class="card">
        <h2>Run Differential</h2>
        <table>
            <tr>
                <th>Team</th>
                <th>Runs Scored</th>
                <th>Runs Allowed</th>
                <th>Differential</th>
                <th>Avg RS/Game</th>
                <th>Avg RA/Game</th>
            </tr>
            {% for rd in run_diff_data %}
            <tr>
                <td>{{ rd.team_name }}</td>
                <td>{{ rd.runs_scored }}</td>
                <td>{{ rd.runs_allowed }}</td>
                <td class="{{ 'winner' if rd.differential > 0 else 'loser' }}">{{ "%+d"|format(rd.differential) }}</td>
                <td>{{ "%.2f"|format(rd.avg_runs_scored) }}</td>
                <td>{{ "%.2f"|format(rd.avg_runs_allowed) }}</td>
            </tr>
            {% endfor %}
        </table>
    </div>
    {% endif %}

    <footer>
        Generated by MLB Rivalry Tracker
    </footer>

    <script>
        {{ line_chart_json }}
        Plotly.newPlot('line-chart', lineData.data, lineData.layout, {responsive: true});
        
        {{ bar_chart_json }}
        Plotly.newPlot('bar-chart', barData.data, barData.layout, {responsive: true});
    </script>
</body>
</html>
"""


class RivalryCharts:
    """Generates visualizations for rivalry data.
    
    This class creates various charts and exports data in multiple formats
    including PNG, JSON, Excel, and HTML reports.
    
    Attributes:
        output_dir: Directory where output files are saved.
    
    Example:
        >>> charts = RivalryCharts(output_dir='results/')
        >>> charts.create_all_charts(stats, save_png=True, save_json=True)
    """

    def __init__(self, output_dir: str = DEFAULT_OUTPUT_DIR) -> None:
        """Initialize the chart generator.
        
        Args:
            output_dir: Directory path for saving output files.
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def _save_line_chart_png(self, stats: RivalryStats, filepath: Path) -> None:
        """Create line chart PNG using matplotlib.
        
        Args:
            stats: RivalryStats object with the data.
            filepath: Path where the PNG will be saved.
        """
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
        """Create bar chart PNG using matplotlib.
        
        Args:
            stats: RivalryStats object with the data.
            filepath: Path where the PNG will be saved.
        """
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
        """Generate a file name prefix for outputs.
        
        Args:
            stats: RivalryStats object with team and year info.
            
        Returns:
            Formatted string prefix for output filenames.
        """
        return f"Rivalry_{stats.team1_name}_vs_{stats.team2_name}_{stats.start_year}_to_{stats.end_year}"

    def create_line_chart(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> go.Figure:
        """Create a line chart showing wins per year.

        Args:
            stats: Rivalry statistics object.
            save_json: Whether to save as JSON file.
            save_png: Whether to save as PNG image.
            show: Whether to display the chart in browser.

        Returns:
            Plotly Figure object.
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
        """Create a bar chart showing total wins.

        Args:
            stats: Rivalry statistics object.
            save_json: Whether to save as JSON file.
            save_png: Whether to save as PNG image.
            show: Whether to display the chart in browser.

        Returns:
            Plotly Figure object.
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

    def create_home_away_chart(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> go.Figure:
        """Create a grouped bar chart showing home/away splits.
        
        Args:
            stats: Rivalry statistics object.
            save_json: Whether to save as JSON file.
            save_png: Whether to save as PNG image.
            show: Whether to display the chart in browser.
            
        Returns:
            Plotly Figure object.
        """
        if not stats.home_away_splits:
            logger.warning("No home/away split data available")
            return go.Figure()
        
        data = []
        for team_name, split in stats.home_away_splits.items():
            data.extend([
                {'Team': team_name, 'Location': 'Home', 'Wins': split.home_wins},
                {'Team': team_name, 'Location': 'Away', 'Wins': split.away_wins},
            ])
        
        df = pd.DataFrame(data)
        
        fig = px.bar(
            df,
            x='Team',
            y='Wins',
            color='Location',
            barmode='group',
            title=f'Home/Away Wins: {stats.team1_name} vs {stats.team2_name}',
            color_discrete_map={'Home': '#2E7D32', 'Away': '#1565C0'},
        )
        
        prefix = self._get_file_prefix(stats)
        if save_json:
            fig.write_json(self.output_dir / f"{prefix}_HomeAway.json")
        if save_png:
            fig.write_image(self.output_dir / f"{prefix}_HomeAway.png")
        if show:
            fig.show()
        
        return fig

    def create_run_differential_chart(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        show: bool = False,
    ) -> go.Figure:
        """Create a bar chart showing run differential.
        
        Args:
            stats: Rivalry statistics object.
            save_json: Whether to save as JSON file.
            save_png: Whether to save as PNG image.
            show: Whether to display the chart in browser.
            
        Returns:
            Plotly Figure object.
        """
        if not stats.run_differentials:
            logger.warning("No run differential data available")
            return go.Figure()
        
        data = []
        for team_name, rd in stats.run_differentials.items():
            data.append({
                'Team': team_name,
                'Differential': rd.differential,
                'Color': 'positive' if rd.differential >= 0 else 'negative',
            })
        
        df = pd.DataFrame(data)
        
        fig = px.bar(
            df,
            x='Team',
            y='Differential',
            color='Color',
            title=f'Run Differential: {stats.team1_name} vs {stats.team2_name}',
            color_discrete_map={'positive': '#2E7D32', 'negative': '#C62828'},
        )
        
        fig.update_layout(showlegend=False)
        fig.add_hline(y=0, line_dash="dash", line_color="gray")
        
        prefix = self._get_file_prefix(stats)
        if save_json:
            fig.write_json(self.output_dir / f"{prefix}_RunDiff.json")
        if save_png:
            fig.write_image(self.output_dir / f"{prefix}_RunDiff.png")
        if show:
            fig.show()
        
        return fig

    def export_to_excel(self, stats: RivalryStats) -> str:
        """Export all rivalry data to an Excel file.
        
        Creates a multi-sheet Excel workbook with:
        - Summary statistics
        - Game-by-game data
        - Wins by year
        - Home/away splits
        - Win streaks
        - Run differentials
        
        Args:
            stats: RivalryStats object with all data.
            
        Returns:
            Path to the created Excel file.
        """
        prefix = self._get_file_prefix(stats)
        filepath = self.output_dir / f"{prefix}.xlsx"
        
        with pd.ExcelWriter(filepath, engine='openpyxl') as writer:
            # Summary sheet
            summary_data = {
                'Metric': [
                    'Team 1', 'Team 2', 'Start Year', 'End Year',
                    'Total Games', 'Team 1 Wins', 'Team 2 Wins', 'Overall Leader'
                ],
                'Value': [
                    stats.team1_name, stats.team2_name, stats.start_year, stats.end_year,
                    stats.total_games, stats.team1_wins, stats.team2_wins, stats.winner_name
                ]
            }
            pd.DataFrame(summary_data).to_excel(writer, sheet_name='Summary', index=False)
            
            # Games sheet
            games_df = stats.games_df.copy()
            games_df['date'] = games_df['date'].dt.strftime('%Y-%m-%d')
            games_df.to_excel(writer, sheet_name='All Games', index=False)
            
            # Wins by year
            stats.wins_by_year.to_excel(writer, sheet_name='Wins By Year')
            
            # Home/Away splits
            if stats.home_away_splits:
                splits_data = []
                for team_name, split in stats.home_away_splits.items():
                    splits_data.append({
                        'Team': team_name,
                        'Home Wins': split.home_wins,
                        'Home Losses': split.home_losses,
                        'Home Win %': f"{split.home_win_pct:.3f}",
                        'Away Wins': split.away_wins,
                        'Away Losses': split.away_losses,
                        'Away Win %': f"{split.away_win_pct:.3f}",
                    })
                pd.DataFrame(splits_data).to_excel(writer, sheet_name='Home Away Splits', index=False)
            
            # Win streaks
            if stats.longest_win_streaks:
                streaks_data = []
                for team_name, streak in stats.longest_win_streaks.items():
                    streaks_data.append({
                        'Team': team_name,
                        'Longest Streak': streak.length,
                        'Start Date': streak.start_date,
                        'End Date': streak.end_date,
                    })
                pd.DataFrame(streaks_data).to_excel(writer, sheet_name='Win Streaks', index=False)
            
            # Run differentials
            if stats.run_differentials:
                rd_data = []
                for team_name, rd in stats.run_differentials.items():
                    rd_data.append({
                        'Team': team_name,
                        'Runs Scored': rd.runs_scored,
                        'Runs Allowed': rd.runs_allowed,
                        'Differential': rd.differential,
                        'Avg Runs Scored': f"{rd.avg_runs_scored:.2f}",
                        'Avg Runs Allowed': f"{rd.avg_runs_allowed:.2f}",
                    })
                pd.DataFrame(rd_data).to_excel(writer, sheet_name='Run Differential', index=False)
        
        logger.info(f"Excel file saved: {filepath}")
        return str(filepath)

    def export_to_html(
        self,
        stats: RivalryStats,
        line_fig: go.Figure,
        bar_fig: go.Figure,
    ) -> str:
        """Export rivalry data to an interactive HTML report.
        
        Creates a single HTML file with embedded charts and statistics tables.
        
        Args:
            stats: RivalryStats object with all data.
            line_fig: Plotly line chart figure.
            bar_fig: Plotly bar chart figure.
            
        Returns:
            Path to the created HTML file.
        """
        from jinja2 import Template
        
        prefix = self._get_file_prefix(stats)
        filepath = self.output_dir / f"{prefix}_Report.html"
        
        # Prepare template data
        template = Template(HTML_TEMPLATE)
        
        # Prepare home/away data
        home_away_data = []
        if stats.home_away_splits:
            for split in stats.home_away_splits.values():
                home_away_data.append(split)
        
        # Prepare streak data
        streak_data = []
        if stats.longest_win_streaks:
            for streak in stats.longest_win_streaks.values():
                streak_data.append(streak)
        
        # Prepare run differential data
        run_diff_data = []
        if stats.run_differentials:
            for rd in stats.run_differentials.values():
                run_diff_data.append(rd)
        
        html_content = template.render(
            title=f"{stats.team1_name} vs {stats.team2_name} Rivalry Report",
            team1_name=stats.team1_name,
            team2_name=stats.team2_name,
            start_year=stats.start_year,
            end_year=stats.end_year,
            total_games=stats.total_games,
            team1_wins=stats.team1_wins,
            team2_wins=stats.team2_wins,
            winner_name=stats.winner_name,
            home_away_data=home_away_data,
            streak_data=streak_data,
            run_diff_data=run_diff_data,
            line_chart_json=f"var lineData = {line_fig.to_json()};",
            bar_chart_json=f"var barData = {bar_fig.to_json()};",
        )
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        logger.info(f"HTML report saved: {filepath}")
        return str(filepath)

    def create_all_charts(
        self,
        stats: RivalryStats,
        save_json: bool = True,
        save_png: bool = True,
        save_excel: bool = True,
        save_html: bool = True,
        show: bool = False,
    ) -> Dict[str, Any]:
        """Create all visualizations and exports.

        Args:
            stats: Rivalry statistics object.
            save_json: Whether to save charts as JSON.
            save_png: Whether to save charts as PNG.
            save_excel: Whether to export to Excel.
            save_html: Whether to generate HTML report.
            show: Whether to display the charts in browser.

        Returns:
            Dictionary containing figure objects and file paths.
        """
        results: Dict[str, Any] = {'figures': {}, 'files': []}
        
        # Create charts
        line_fig = self.create_line_chart(stats, save_json, save_png, show)
        bar_fig = self.create_bar_chart(stats, save_json, save_png, show)
        
        results['figures']['line'] = line_fig
        results['figures']['bar'] = bar_fig
        
        # Create additional charts if data available
        if stats.home_away_splits:
            home_away_fig = self.create_home_away_chart(stats, save_json, save_png, show)
            results['figures']['home_away'] = home_away_fig
        
        if stats.run_differentials:
            run_diff_fig = self.create_run_differential_chart(stats, save_json, save_png, show)
            results['figures']['run_diff'] = run_diff_fig
        
        # Export to Excel
        if save_excel:
            excel_path = self.export_to_excel(stats)
            results['files'].append(excel_path)
        
        # Export to HTML
        if save_html:
            html_path = self.export_to_html(stats, line_fig, bar_fig)
            results['files'].append(html_path)
        
        return results
