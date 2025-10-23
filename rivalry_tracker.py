import statsapi
import pandas as pd
import matplotlib.pyplot as plt
import os

# === TEAM CODE MAPPING (ID + COLOR + NAME) ===
team_code_map = {
    'ana': {'id': 108, 'color': '#BA0021', 'name': 'Los Angeles Angels'},
    'ari': {'id': 109, 'color': '#A71930', 'name': 'Arizona Diamondbacks'},
    'atl': {'id': 144, 'color': '#CE1141', 'name': 'Atlanta Braves'},
    'bal': {'id': 110, 'color': '#DF4601', 'name': 'Baltimore Orioles'},
    'bos': {'id': 111, 'color': '#BD3039', 'name': 'Boston Red Sox'},
    'cha': {'id': 145, 'color': '#27251F', 'name': 'Chicago White Sox'},
    'chn': {'id': 112, 'color': '#0E3386', 'name': 'Chicago Cubs'},
    'cin': {'id': 113, 'color': '#C6011F', 'name': 'Cincinnati Reds'},
    'cle': {'id': 114, 'color': '#E31937', 'name': 'Cleveland Guardians'},
    'col': {'id': 115, 'color': '#33006F', 'name': 'Colorado Rockies'},
    'det': {'id': 116, 'color': '#0C2340', 'name': 'Detroit Tigers'},
    'hou': {'id': 117, 'color': '#002D62', 'name': 'Houston Astros'},
    'kca': {'id': 118, 'color': '#004687', 'name': 'Kansas City Royals'},
    'lan': {'id': 119, 'color': '#005A9C', 'name': 'Los Angeles Dodgers'},
    'mia': {'id': 146, 'color': '#0077C8', 'name': 'Miami Marlins'},
    'mil': {'id': 158, 'color': '#12284B', 'name': 'Milwaukee Brewers'},
    'min': {'id': 142, 'color': '#002B5C', 'name': 'Minnesota Twins'},
    'mon': {'id': 120, 'color': '#67ABE5', 'name': 'Montreal Expos'},
    'nya': {'id': 147, 'color': '#132448', 'name': 'New York Yankees'},
    'nyn': {'id': 121, 'color': '#002D72', 'name': 'New York Mets'},
    'oak': {'id': 133, 'color': '#003831', 'name': 'Oakland Athletics'},
    'phi': {'id': 143, 'color': '#E81828', 'name': 'Philadelphia Phillies'},
    'pit': {'id': 134, 'color': '#FDB827', 'name': 'Pittsburgh Pirates'},
    'sdn': {'id': 135, 'color': '#2F241D', 'name': 'San Diego Padres'},
    'sea': {'id': 136, 'color': '#0C2C56', 'name': 'Seattle Mariners'},
    'sfn': {'id': 137, 'color': '#FD5A1E', 'name': 'San Francisco Giants'},
    'sln': {'id': 138, 'color': '#C41E3A', 'name': 'St. Louis Cardinals'},
    'tba': {'id': 139, 'color': '#092C5C', 'name': 'Tampa Bay Rays'},
    'tex': {'id': 140, 'color': '#003278', 'name': 'Texas Rangers'},
    'tor': {'id': 141, 'color': '#134A8E', 'name': 'Toronto Blue Jays'},
    'was': {'id': 120, 'color': '#AB0003', 'name': 'Washington Nationals'},
    'alas': {'id': 159, 'color': '#041E42', 'name': 'AL All-Stars'},
    'nlas': {'id': 160, 'color': '#EE0A46', 'name': 'NL All-Stars'}
}

# === USER INPUT ===
team1_code = input("Enter first team code (e.g., 'nya'): ").lower()
team2_code = input("Enter second team code (e.g., 'bos'): ").lower()
start_year = int(input("Enter start year (e.g., 1995): "))
end_year = int(input("Enter end year (e.g., 2004): "))

# Validate team codes
if team1_code not in team_code_map or team2_code not in team_code_map:
    raise ValueError("Invalid team code entered.")

team1_id = team_code_map[team1_code]['id']
team2_id = team_code_map[team2_code]['id']
team1_color = team_code_map[team1_code]['color']
team2_color = team_code_map[team2_code]['color']
team1_name = team_code_map[team1_code]['name']
team2_name = team_code_map[team2_code]['name']

# === DATA COLLECTION BY SEASON ===
games = []
for year in range(start_year, end_year + 1):
    schedule = statsapi.schedule(team=team1_id, opponent=team2_id, season=year)
    for game in schedule:
        winner = game.get('winning_team', 'Unknown')
        games.append({
            'date': game['game_date'],
            'winner': winner
        })

# === DATA ANALYSIS ===
df = pd.DataFrame(games)
df['year'] = pd.to_datetime(df['date']).dt.year
win_counts = df.groupby(['year', 'winner']).size().unstack(fill_value=0)

# === EXPORT TO CSV ===
os.makedirs('output', exist_ok=True)
csv_filename = f"output/Rivalry_Data_{team1_name}_vs_{team2_name}_{start_year}_to_{end_year}.csv"
df.to_csv(csv_filename, index=False)
print(f"CSV export completed: {csv_filename}")


# === LINE CHART: Wins Per Year ===
fig_line = px.line(
    win_counts,
    markers=True,
    title=f'Rivalry Wins Per Year: {team1_name} vs {team2_name} ({start_year}–{end_year})',
    labels={'value': 'Number of Wins', 'year': 'Year'},
    color_discrete_map={team1_name: team1_color, team2_name: team2_color}
)
fig_line.write_json(f'output/Rivalry_Wins_LineChart.json')
fig_line.write_image(f'output/Rivalry_Wins_LineChart.png')

# === BAR CHART: Total Wins ===
total_wins_filtered = df['winner'].value_counts()
fig_bar = px.bar(
    total_wins_filtered,
    title='Total Wins by Team',
    labels={'index': 'Team', 'value': 'Number of Wins'},
    color=total_wins_filtered.index.map({team1_name: team1_color, team2_name: team2_color})
)
fig_bar.write_json('output/Total_Wins_Bar_Chart.json')
fig_bar.write_image('output/Total_Wins_Bar_Chart.png')

print("CSV and visualizations have been generated successfully.")