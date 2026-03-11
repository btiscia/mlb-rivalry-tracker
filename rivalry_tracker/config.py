"""Configuration and team mappings for MLB Rivalry Tracker."""

from dataclasses import dataclass
from typing import Dict, Optional


@dataclass(frozen=True)
class TeamInfo:
    """Immutable team information."""
    id: int
    color: str
    name: str


# === TEAM CODE MAPPING (ID + COLOR + NAME) ===
TEAM_CODE_MAP: Dict[str, TeamInfo] = {
    'ana': TeamInfo(id=108, color='#BA0021', name='Los Angeles Angels'),
    'ari': TeamInfo(id=109, color='#A71930', name='Arizona Diamondbacks'),
    'atl': TeamInfo(id=144, color='#CE1141', name='Atlanta Braves'),
    'bal': TeamInfo(id=110, color='#DF4601', name='Baltimore Orioles'),
    'bos': TeamInfo(id=111, color='#BD3039', name='Boston Red Sox'),
    'cha': TeamInfo(id=145, color='#27251F', name='Chicago White Sox'),
    'chn': TeamInfo(id=112, color='#0E3386', name='Chicago Cubs'),
    'cin': TeamInfo(id=113, color='#C6011F', name='Cincinnati Reds'),
    'cle': TeamInfo(id=114, color='#E31937', name='Cleveland Guardians'),
    'col': TeamInfo(id=115, color='#33006F', name='Colorado Rockies'),
    'det': TeamInfo(id=116, color='#0C2340', name='Detroit Tigers'),
    'hou': TeamInfo(id=117, color='#002D62', name='Houston Astros'),
    'kca': TeamInfo(id=118, color='#004687', name='Kansas City Royals'),
    'lan': TeamInfo(id=119, color='#005A9C', name='Los Angeles Dodgers'),
    'mia': TeamInfo(id=146, color='#0077C8', name='Miami Marlins'),
    'mil': TeamInfo(id=158, color='#12284B', name='Milwaukee Brewers'),
    'min': TeamInfo(id=142, color='#002B5C', name='Minnesota Twins'),
    'mon': TeamInfo(id=120, color='#67ABE5', name='Montreal Expos'),
    'nya': TeamInfo(id=147, color='#132448', name='New York Yankees'),
    'nyn': TeamInfo(id=121, color='#002D72', name='New York Mets'),
    'oak': TeamInfo(id=133, color='#003831', name='Oakland Athletics'),
    'phi': TeamInfo(id=143, color='#E81828', name='Philadelphia Phillies'),
    'pit': TeamInfo(id=134, color='#FDB827', name='Pittsburgh Pirates'),
    'sdn': TeamInfo(id=135, color='#2F241D', name='San Diego Padres'),
    'sea': TeamInfo(id=136, color='#0C2C56', name='Seattle Mariners'),
    'sfn': TeamInfo(id=137, color='#FD5A1E', name='San Francisco Giants'),
    'sln': TeamInfo(id=138, color='#C41E3A', name='St. Louis Cardinals'),
    'tba': TeamInfo(id=139, color='#092C5C', name='Tampa Bay Rays'),
    'tex': TeamInfo(id=140, color='#003278', name='Texas Rangers'),
    'tor': TeamInfo(id=141, color='#134A8E', name='Toronto Blue Jays'),
    'was': TeamInfo(id=120, color='#AB0003', name='Washington Nationals'),
    'alas': TeamInfo(id=159, color='#041E42', name='AL All-Stars'),
    'nlas': TeamInfo(id=160, color='#EE0A46', name='NL All-Stars'),
}

# Chart color constants
WINNER_COLOR = '#00B0F0'  # Blue for more wins
LOSER_COLOR = '#C00000'   # Red for fewer wins

# Default settings
DEFAULT_OUTPUT_DIR = 'output'
DEFAULT_CACHE_DIR = '.cache'
MAX_API_WORKERS = 5
API_RETRY_ATTEMPTS = 3
API_RETRY_DELAY = 1.0  # seconds


def get_team(code: str) -> Optional[TeamInfo]:
    """Get team info by code (case-insensitive)."""
    return TEAM_CODE_MAP.get(code.lower())


def validate_team_codes(*codes: str) -> None:
    """Validate that all team codes exist."""
    for code in codes:
        if code.lower() not in TEAM_CODE_MAP:
            valid_codes = ', '.join(sorted(TEAM_CODE_MAP.keys()))
            raise ValueError(
                f"Invalid team code: '{code}'. Valid codes are: {valid_codes}"
            )


def list_teams() -> None:
    """Print all available team codes and names."""
    print("\nAvailable Teams:")
    print("-" * 40)
    for code, team in sorted(TEAM_CODE_MAP.items(), key=lambda x: x[1].name):
        print(f"  {code:5} - {team.name}")
    print()
