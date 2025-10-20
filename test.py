import statsapi
from datetime import datetime, timedelta
import json

def fetch_schedule_range(start_date, end_date, team=None, opponent=None, output_file="schedule_range.json"):
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    delta = timedelta(days=1)

    all_games = []

    while start <= end:
        date_str = start.strftime("%Y-%m-%d")
        games = statsapi.schedule(date=date_str, team=team, opponent=opponent)
        all_games.extend(games)
        start += delta

    # Save to JSON
    with open(output_file, "w") as f:
        json.dump(all_games, f, indent=2)

    print(f"Saved {len(all_games)} games to {output_file}")

fetch_schedule_range("2025-09-01", "2025-10-07", team="147", opponent="111")
