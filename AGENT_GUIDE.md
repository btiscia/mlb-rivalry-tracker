# MLB Rivalry Tracker — Agent Reference Guide

## What This Repo Is

A Python CLI tool that fetches head-to-head game data between any two MLB teams over a user-specified year range from the MLB Stats API, performs statistical analysis, and generates visualizations and exports (PNG, JSON, CSV, Excel, HTML).

**Version:** 1.1.0  
**Python:** 3.9+  
**License:** MIT  
**Owner:** btiscia  

---

## Architecture Overview

```
rivalry_tracker/
├── __init__.py          # Package exports, public API surface
├── __main__.py          # Enables `python -m rivalry_tracker`
├── cli.py               # Argument parsing (argparse)
├── config.py            # Team code map, constants, TeamInfo dataclass
├── main.py              # Pipeline orchestrator (run function + CLI entry point)
├── api/
│   └── fetcher.py       # MLB Stats API client with caching + parallel fetch
├── analysis/
│   └── stats.py         # Statistical computation (wins, streaks, splits, run diff)
└── visualization/
    └── charts.py        # Chart generation (Plotly + matplotlib) + HTML report
```

---

## Execution Pipeline (in order)

1. **CLI Parsing** (`cli.py`): Parses team codes, year range, and output flags.
2. **Team Resolution** (`config.py`): Looks up 3-letter team codes → `TeamInfo(id, color, name)`.
3. **Data Fetching** (`api/fetcher.py`): Fetches game schedules per year from `statsapi.schedule()` using parallel threads (up to 5 workers). Caches responses as JSON files keyed by MD5 hash of `{team1_id}_{team2_id}_{year}`. Retries with exponential backoff (3 attempts).
4. **Analysis** (`analysis/stats.py`): Converts raw games to a pandas DataFrame. Computes: wins per year per team, home/away splits, longest win streaks, run differentials. Produces a `RivalryStats` dataclass.
5. **Visualization** (`visualization/charts.py`): Generates line chart (wins/year), bar chart (total wins), home/away chart, run differential chart. Outputs: Plotly JSON, matplotlib PNG, Excel workbook, and a self-contained HTML report (Jinja2 template with embedded Plotly JS).
6. **CSV Export** (`main.py`): Writes raw game data to CSV.

---

## Key Data Structures

### `TeamInfo` (frozen dataclass)
```python
@dataclass(frozen=True)
class TeamInfo:
    id: int       # Official MLB team ID (used in API calls)
    color: str    # Hex color for charts (#RRGGBB)
    name: str     # Full team name (e.g., "New York Yankees")
```

### `GameResult` (dataclass)
```python
@dataclass
class GameResult:
    date: str         # "YYYY-MM-DD"
    winner: str       # Full team name of winner
    home_team: str
    away_team: str
    home_score: int
    away_score: int
    game_id: int
```

### `RivalryStats` (dataclass) — the central output object
- `team1_name`, `team2_name`, `start_year`, `end_year`
- `total_games`, `team1_wins`, `team2_wins`
- `wins_by_year`: pandas DataFrame (index=year, columns=team names)
- `winner_name`, `loser_name`: determined by who has more total wins
- `color_map`: `{winner_name: '#00B0F0', loser_name: '#C00000'}`
- `games_df`: full pandas DataFrame of all games
- `home_away_splits`: `Dict[str, HomeAwaySplit]`
- `longest_win_streaks`: `Dict[str, WinStreak]`
- `run_differentials`: `Dict[str, RunDifferential]`

---

## Team Code System

Teams are identified by 2–4 letter codes (e.g., `nya` = Yankees, `bos` = Red Sox, `chn` = Cubs, `sln` = Cardinals). The full map is in `config.py` under `TEAM_CODE_MAP`. There are 32 entries including historical (Montreal Expos) and All-Star teams. The Expos (`mon`) and Nationals (`was`) share MLB ID 120 due to franchise relocation.

---

## External Dependencies

| Package | Purpose |
|---------|---------|
| `MLB-StatsAPI` (statsapi) | Wraps the official MLB Stats API |
| `pandas` | DataFrame operations for analysis |
| `plotly` | Interactive chart generation (JSON export) |
| `matplotlib` | Static PNG chart rendering |
| `tqdm` | Progress bars during fetch |
| `openpyxl` | Excel workbook export |
| `Jinja2` | HTML report templating |

---

## Caching Mechanism

- Cache dir: `.cache/` (configurable via `--cache-dir`)
- Key: MD5 hash of `"{team1_id}_{team2_id}_{year}"`
- Storage: one JSON file per season query
- Behavior: cache hit skips API call; corrupted cache files are ignored
- CLI flags: `--no-cache` (disable), `--clear-cache` (delete all cached files and exit)

---

## CLI Usage

```bash
python -m rivalry_tracker <team1> <team2> <start_year> <end_year> [options]
```

Key options:
- `-o / --output`: output directory (default: `output/`)
- `--no-png`, `--no-json`, `--no-csv`, `--no-excel`, `--no-html`: skip specific outputs
- `--show`: open charts in browser
- `--no-cache`: bypass cache
- `--clear-cache`: wipe cache and exit
- `-l / --list-teams`: print team codes and exit
- `-v / --verbose`: debug-level logging

Installed entry point: `rivalry-tracker` (via `pyproject.toml` scripts).

---

## Output Files (naming pattern)

All outputs use the prefix: `Rivalry_{Team1Name}_vs_{Team2Name}_{StartYear}_to_{EndYear}`

| Suffix | Content |
|--------|---------|
| `_Data_...csv` | Raw game data |
| `_Line.json` | Plotly line chart (wins/year) |
| `_Bar.json` | Plotly bar chart (total wins) |
| `_HomeAway.json` | Plotly home/away chart |
| `_RunDiff.json` | Plotly run differential chart |
| `_Line.png` | Matplotlib line chart |
| `_Bar.png` | Matplotlib bar chart |
| `_HomeAway.png` | Matplotlib home/away chart |
| `_RunDiff.png` | Matplotlib run differential chart |
| `_Report.html` | Self-contained interactive HTML report |
| `.xlsx` | Excel workbook (multiple sheets) |

---

## Testing

Tests live in `tests/` and use pytest with pytest-mock. Key test files:
- `test_fetcher.py`: API fetching, caching, retry logic
- `test_analysis.py`: Statistical computation correctness
- `test_cli.py`: Argument parsing validation
- `test_config.py`: Team lookup and validation

Run: `pytest` (configured in `pyproject.toml`).

---

## Configuration Constants (`config.py`)

| Constant | Value | Purpose |
|----------|-------|---------|
| `DEFAULT_OUTPUT_DIR` | `'output'` | Default output directory |
| `DEFAULT_CACHE_DIR` | `'.cache'` | Default cache directory |
| `MAX_API_WORKERS` | `5` | Thread pool size for parallel fetching |
| `API_RETRY_ATTEMPTS` | `3` | Max retries per API call |
| `API_RETRY_DELAY` | `1.0` | Base delay (seconds) for exponential backoff |
| `WINNER_COLOR` | `'#00B0F0'` | Blue — team with more wins |
| `LOSER_COLOR` | `'#C00000'` | Red — team with fewer wins |

---

## Programmatic Usage (no CLI)

```python
from rivalry_tracker import run

run(
    team1_code='nya',
    team2_code='bos',
    start_year=1995,
    end_year=2004,
    output_dir='output',
    use_cache=True,
    save_csv=True,
    save_png=True,
    save_json=True,
    save_excel=True,
    save_html=True,
)
```

Or use individual components:
```python
from rivalry_tracker import get_team, RivalryFetcher, RivalryAnalyzer, RivalryCharts

team1 = get_team('nya')
team2 = get_team('bos')

fetcher = RivalryFetcher(use_cache=True)
games = fetcher.fetch_rivalry_data(team1, team2, 2020, 2023)

analyzer = RivalryAnalyzer(team1, team2)
stats = analyzer.analyze(games, 2020, 2023)

charts = RivalryCharts(output_dir='output')
charts.create_all_charts(stats)
```

---

## Error Handling

- `APIError`: raised after all retries exhausted for a year
- `CacheError`: raised on cache operation failure
- `ValueError`: invalid team codes, invalid year ranges, no games found
- The pipeline is fail-tolerant per year: if one year fails, others still return data (errors are logged as warnings)

---

## Build & Install

```bash
pip install -e .           # Editable install
pip install -e ".[dev]"    # With dev dependencies (pytest, ruff, mypy)
```

Build system: setuptools (configured in `pyproject.toml`).
