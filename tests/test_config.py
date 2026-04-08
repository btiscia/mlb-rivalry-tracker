"""Tests for configuration module."""

import pytest

from rivalry_tracker.config import (
    TEAM_CODE_MAP,
    TeamInfo,
    get_team,
    list_teams,
    validate_team_codes,
)


class TestTeamCodeMap:
    """Tests for the team code mapping."""

    def test_all_teams_have_required_fields(self):
        """Every team should have id, color, and name."""
        for code, team in TEAM_CODE_MAP.items():
            assert isinstance(team, TeamInfo)
            assert isinstance(team.id, int)
            assert team.id > 0
            assert isinstance(team.color, str)
            assert team.color.startswith('#')
            assert len(team.color) == 7  # #RRGGBB format
            assert isinstance(team.name, str)
            assert len(team.name) > 0

    def test_common_team_codes_exist(self):
        """Common team codes should be available."""
        common_teams = ['nya', 'bos', 'lan', 'sfn', 'chn', 'sln']
        for code in common_teams:
            assert code in TEAM_CODE_MAP, f"Missing team code: {code}"

    def test_team_info_is_immutable(self):
        """TeamInfo should be immutable (frozen dataclass)."""
        team = TEAM_CODE_MAP['nya']
        with pytest.raises(Exception):
            team.name = "Changed Name"


class TestGetTeam:
    """Tests for get_team function."""

    def test_get_valid_team(self):
        """Should return team info for valid codes."""
        team = get_team('nya')
        assert team is not None
        assert team.name == 'New York Yankees'
        assert team.id == 147

    def test_get_team_case_insensitive(self):
        """Should work with any case."""
        lower = get_team('nya')
        upper = get_team('NYA')
        mixed = get_team('NyA')
        
        assert lower == upper == mixed

    def test_get_invalid_team_returns_none(self):
        """Should return None for invalid codes."""
        assert get_team('invalid') is None
        assert get_team('xyz') is None
        assert get_team('') is None


class TestValidateTeamCodes:
    """Tests for validate_team_codes function."""

    def test_valid_codes_pass(self):
        """Valid codes should not raise exception."""
        validate_team_codes('nya', 'bos')  # Should not raise

    def test_invalid_code_raises_value_error(self):
        """Invalid codes should raise ValueError."""
        with pytest.raises(ValueError) as exc_info:
            validate_team_codes('nya', 'invalid')
        
        assert 'invalid' in str(exc_info.value).lower()

    def test_multiple_codes_validated(self):
        """All codes should be validated."""
        with pytest.raises(ValueError):
            validate_team_codes('invalid1', 'invalid2')


class TestListTeams:
    """Tests for list_teams function."""

    def test_list_teams_outputs(self, capsys):
        """Should print team list to stdout."""
        list_teams()
        captured = capsys.readouterr()
        
        assert 'Yankees' in captured.out
        assert 'Red Sox' in captured.out
        assert 'nya' in captured.out
        assert 'bos' in captured.out
