import statsapi
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import os

# === USER INPUT ===
team1_id = 147  # Yankees
team2_id = 111  # Red Sox
start_date = "2010-01-01"
end_date = "2025-10-07"

# === DATA COLLECTION ===
start = datetime.strptime(start_date, "%Y-%m-%d")
end = datetime.strptime(end_date, "%Y-%m-%d")
delta = timedelta(days=1)

games = []

while start <= end:
    date_str = start.strftime("%Y-%m-%d")
    schedule = statsapi.schedule(date=date_str, team=str(team1_id), opponent=str(team2_id))
    for game in schedule:
        try:
            winner = game['winning_team']
        except KeyError:
            winner = "Unknown"
        games.append({
            'date': game['game_date'],
            'home': game['home_name'],
            'away': game['away_name'],
            'winner': winner
        })
    start += delta

# === DATA ANALYSIS ===
df = pd.DataFrame(games)
win_counts = df.groupby(['date', 'winner']).size().unstack(fill_value=0)

# === VISUALIZATION ===
os.makedirs('output', exist_ok=True)
plt.figure(figsize=(12, 6))
win_counts.plot(kind='bar', stacked=True, colormap='coolwarm')
plt.title(f'Rivalry Wins: Team {team1_id} vs Team {team2_id} ({start_date} to {end_date})')
plt.xlabel('Date')
plt.ylabel('Number of Wins')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('output/rivalry_wins.png')
plt.show()