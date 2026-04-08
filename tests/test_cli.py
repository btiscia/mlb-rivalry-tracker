"""Tests for CLI module."""

import pytest

from rivalry_tracker.cli import create_parser, parse_args, validate_args


class TestCreateParser:
    """Tests for parser creation."""

    def test_parser_created(self):
        """Parser should be created successfully."""
        parser = create_parser()
        assert parser is not None

    def test_parser_has_required_arguments(self):
        """Parser should have all expected arguments."""
        parser = create_parser()
        
        # Parse with all required args
        args = parser.parse_args(['nya', 'bos', '2020', '2021'])
        
        assert args.team1 == 'nya'
        assert args.team2 == 'bos'
        assert args.start_year == 2020
        assert args.end_year == 2021


class TestValidateArgs:
    """Tests for argument validation."""

    def test_valid_args_return_none(self):
        """Valid arguments should return None (no error)."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021'])
        
        error = validate_args(args)
        
        assert error is None

    def test_missing_args_return_error(self):
        """Missing required args should return error message."""
        parser = create_parser()
        args = parser.parse_args([])  # No args
        
        error = validate_args(args)
        
        assert error is not None
        assert 'missing' in error.lower()

    def test_invalid_team_returns_error(self):
        """Invalid team code should return error message."""
        parser = create_parser()
        args = parser.parse_args(['invalid', 'bos', '2020', '2021'])
        
        error = validate_args(args)
        
        assert error is not None
        assert 'invalid' in error.lower()

    def test_start_after_end_returns_error(self):
        """Start year after end year should return error."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2021', '2020'])
        
        error = validate_args(args)
        
        assert error is not None
        assert 'start' in error.lower() or '2021' in error

    def test_year_before_1871_returns_error(self):
        """Year before 1871 should return error."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '1800', '1850'])
        
        error = validate_args(args)
        
        assert error is not None
        assert '1871' in error

    def test_list_teams_flag_valid(self):
        """--list-teams should be valid without other args."""
        parser = create_parser()
        args = parser.parse_args(['--list-teams'])
        
        error = validate_args(args)
        
        assert error is None

    def test_clear_cache_flag_valid(self):
        """--clear-cache should be valid without other args."""
        parser = create_parser()
        args = parser.parse_args(['--clear-cache'])
        
        error = validate_args(args)
        
        assert error is None


class TestOptionalArguments:
    """Tests for optional CLI arguments."""

    def test_output_directory(self):
        """Should accept custom output directory."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '-o', 'custom_output'])
        
        assert args.output == 'custom_output'

    def test_cache_directory(self):
        """Should accept custom cache directory."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--cache-dir', 'my_cache'])
        
        assert args.cache_dir == 'my_cache'

    def test_no_cache_flag(self):
        """--no-cache flag should disable caching."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--no-cache'])
        
        assert args.no_cache is True

    def test_verbose_flag(self):
        """--verbose flag should enable verbose output."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--verbose'])
        
        assert args.verbose is True

    def test_show_flag(self):
        """--show flag should enable chart display."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--show'])
        
        assert args.show is True

    def test_no_png_flag(self):
        """--no-png flag should skip PNG generation."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--no-png'])
        
        assert args.no_png is True

    def test_no_json_flag(self):
        """--no-json flag should skip JSON generation."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--no-json'])
        
        assert args.no_json is True

    def test_no_csv_flag(self):
        """--no-csv flag should skip CSV generation."""
        parser = create_parser()
        args = parser.parse_args(['nya', 'bos', '2020', '2021', '--no-csv'])
        
        assert args.no_csv is True
