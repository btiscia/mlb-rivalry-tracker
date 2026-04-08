# Contributing to MLB Rivalry Tracker

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/btiscia/mlb-rivalry-tracker.git
   cd mlb-rivalry-tracker
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install in development mode**
   ```bash
   pip install -e ".[dev]"
   ```

## Code Style

This project uses:
- **Ruff** for linting and formatting
- **MyPy** for type checking
- **pytest** for testing

### Running Linters

```bash
# Lint code
ruff check .

# Format code
ruff format .

# Type check
mypy rivalry_tracker
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=rivalry_tracker --cov-report=html

# Run specific test file
pytest tests/test_analysis.py

# Run specific test
pytest tests/test_analysis.py::TestRivalryAnalyzer::test_analyze_basic_stats
```

## Code Guidelines

### Type Hints

All public functions should have type hints:

```python
def fetch_data(team_id: int, year: int) -> List[GameResult]:
    """Fetch game data for a team and year."""
    ...
```

### Docstrings

Use Google-style docstrings:

```python
def analyze_rivalry(games: List[GameResult], start_year: int, end_year: int) -> RivalryStats:
    """
    Analyze rivalry game data.

    Args:
        games: List of game results to analyze.
        start_year: First year of the analysis period.
        end_year: Last year of the analysis period.

    Returns:
        RivalryStats object containing computed statistics.

    Raises:
        ValueError: If games list is empty.
    """
    ...
```

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add home/away splits analysis
fix: handle API timeout gracefully
docs: update README with new options
test: add tests for cache functionality
refactor: extract chart generation to separate methods
```

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes**
   - Write tests for new functionality
   - Ensure all tests pass
   - Update documentation if needed

3. **Run quality checks**
   ```bash
   ruff check .
   ruff format .
   mypy rivalry_tracker
   pytest
   ```

4. **Submit a pull request**
   - Provide a clear description of changes
   - Reference any related issues
   - Ensure CI passes

## Project Structure

```
mlb-rivalry-tracker/
├── rivalry_tracker/          # Main package
│   ├── __init__.py
│   ├── __main__.py          # Entry point for python -m
│   ├── main.py              # Main orchestration
│   ├── cli.py               # Command-line interface
│   ├── config.py            # Configuration & constants
│   ├── api/
│   │   ├── __init__.py
│   │   └── fetcher.py       # API client with caching
│   ├── analysis/
│   │   ├── __init__.py
│   │   └── stats.py         # Statistical analysis
│   └── visualization/
│       ├── __init__.py
│       └── charts.py        # Chart generation
├── tests/                   # Test suite
│   ├── conftest.py          # Shared fixtures
│   ├── test_analysis.py
│   ├── test_cli.py
│   ├── test_config.py
│   └── test_fetcher.py
├── pyproject.toml           # Project configuration
├── requirements.txt         # Dependencies
└── README.md
```

## Adding New Features

### New Analysis Types

1. Add the analysis logic to `rivalry_tracker/analysis/stats.py`
2. Update `RivalryStats` dataclass if needed
3. Add visualization in `rivalry_tracker/visualization/charts.py`
4. Add CLI options in `rivalry_tracker/cli.py`
5. Update `run()` function in `rivalry_tracker/main.py`
6. Write tests
7. Update README

### New Export Formats

1. Add export function to `rivalry_tracker/visualization/charts.py`
2. Add CLI option for the format
3. Write tests
4. Update README

## Questions?

Open an issue for any questions about contributing!
