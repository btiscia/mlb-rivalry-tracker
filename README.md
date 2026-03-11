# MLB Rivalry Tracker

This Python app uses `mlbstatsapi` to analyze and visualize MLB rivalries between any two teams over a custom year range.

## Features

- Pulls game data using MLB Stats API
- **Parallel API fetching** for faster data retrieval
- **Caching** to avoid redundant API calls
- **Retry logic** with exponential backoff
- Analyzes win/loss trends
- Visualizes rivalry dynamics with interactive charts

## How to Run

1. Clone this repo

2. Create Virtual Environment

   `python -m venv venv`
3. Activate Virtual Environment

   `venv\Scripts\activate`
4. Install Requirements

   `pip install -r requirements.txt`
5. Run program with two team codes and a range of years (see team code list below)

   ```bash
   # New module-style usage (recommended)
   python -m rivalry_tracker nya bos 1995 2004

   # Or use the legacy script
   python rivalry_tracker.py nya bos 1995 2004
   ```

## Command-Line Options

```
python -m rivalry_tracker [options] team1 team2 start_year end_year

Positional arguments:
  team1           First team code (e.g., 'nya')
  team2           Second team code (e.g., 'bos')
  start_year      Start year (e.g., 1995)
  end_year        End year (e.g., 2004)

Optional arguments:
  -o, --output    Output directory (default: output)
  --cache-dir     Cache directory (default: .cache)
  --no-cache      Disable caching (always fetch from API)
  --clear-cache   Clear the cache and exit
  --no-png        Skip PNG image generation
  --no-json       Skip JSON chart data generation
  --no-csv        Skip CSV data export
  --show          Display charts in browser
  -l, --list-teams List all available team codes
  -v, --verbose   Enable verbose output
```

## Examples

```bash
# Yankees vs Red Sox, 1995-2004
python -m rivalry_tracker nya bos 1995 2004

# Cardinals vs Cubs with custom output folder
python -m rivalry_tracker sln chn 2000 2020 --output results/

# List all team codes
python -m rivalry_tracker --list-teams

# Force fresh API calls (skip cache)
python -m rivalry_tracker nya bos 1990 2000 --no-cache
```

## Project Structure

```
rivalry_tracker/
├── __init__.py          # Package initialization
├── __main__.py          # Entry point for python -m
├── main.py              # Main orchestration
├── cli.py               # Command-line interface
├── config.py            # Team mappings & constants
├── api/
│   └── fetcher.py       # API calls with caching & retry
├── analysis/
│   └── stats.py         # Data processing
└── visualization/
    └── charts.py        # Chart generation
```

## Team Code List

| Team Name              | Team Code |
|------------------------|-----------|
| AL All-Stars           | alas      |
| Arizona Diamondbacks   | ari       |
| Atlanta Braves         | atl       |
| Baltimore Orioles      | bal       |
| Boston Red Sox         | bos       |
| Chicago Cubs           | chn       |
| Chicago White Sox      | cha       |
| Cincinnati Reds        | cin       |
| Cleveland Guardians    | cle       |
| Colorado Rockies       | col       |
| Detroit Tigers         | det       |
| Houston Astros         | hou       |
| Kansas City Royals     | kca       |
| Los Angeles Angels     | ana       |
| Los Angeles Dodgers    | lan       |
| Miami Marlins          | mia       |
| Milwaukee Brewers      | mil       |
| Minnesota Twins        | min       |
| Montreal Expos         | mon       |
| New York Mets          | nyn       |
| New York Yankees       | nya       |
| NL All-Stars           | nlas      |
| Oakland Athletics      | oak       |
| Philadelphia Phillies  | phi       |
| Pittsburgh Pirates     | pit       |
| San Diego Padres       | sdn       |
| San Francisco Giants   | sfn       |
| Seattle Mariners       | sea       |
| St. Louis Cardinals    | sln       |
| Tampa Bay Rays         | tba       |
| Texas Rangers          | tex       |
| Toronto Blue Jays      | tor       |
| Washington Nationals   | was       |
