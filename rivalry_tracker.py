import statsapi
import pandas as pd
import plotly.express as px
import os
import argparse

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

def analyze_team_rivalry(team1_code, team2_code, start_year, end_year, output_dir='output'):
    # Validate team codes
    if team1_code not in team_code_map or team2_code not in team_code_map:
        raise ValueError("Invalid team code entered.")

    team1 = team_code_map[team1_code]
    team2 = team_code_map[team2_code]

    # === DATA COLLECTION BY SEASON ===
    games = []
    for year in range(start_year, end_year + 1):
        schedule = statsapi.schedule(team=team1['id'], opponent=team2['id'], season=year)
        for game in schedule:
            if game.get('status') == 'Final':  # ✅ Only include completed games
                winner = game.get('winning_team', 'Unknown')
                games.append({
                    'date': game['game_date'],
                    'winner': winner
                })

    # === DATA ANALYSIS ===
    df = pd.DataFrame(games)
    df['year'] = pd.to_datetime(df['date']).dt.year
    win_counts = df.groupby(['year', 'winner']).size().unstack(fill_value=0)

    # Determine total wins for color assignment
    total_wins = df['winner'].value_counts()
    if len(total_wins) < 2:
        raise ValueError("Not enough data to compare teams.")
    winner_team = total_wins.idxmax()
    loser_team = total_wins.idxmin()

    # Dynamic color mapping
    color_map = {
        winner_team: '#00B0F0',  # Blue for more wins
        loser_team: '#C00000'    # Red for fewer wins
    }

    # === EXPORT TO CSV ===
    os.makedirs(output_dir, exist_ok=True)
    csv_filename = f"{output_dir}/Rivalry_Data_{team1['name']}_vs_{team2['name']}_{start_year}_to_{end_year}.csv"
    df.to_csv(csv_filename, index=False)
    print(f"CSV export completed: {csv_filename}")

    # === LINE CHART: Wins Per Year ===
    fig_line = px.line(
        win_counts,
        markers=True,
        title=f'Rivalry Wins Per Year: {team1["name"]} vs {team2["name"]} ({start_year}–{end_year})',
        labels={'value': 'Number of Wins', 'year': 'Year'},
        color_discrete_map=color_map
    )
    fig_line.write_json(f'{output_dir}/Rivalry_Wins_LineChart.json')
    fig_line.write_image(f'{output_dir}/Rivalry_Wins_LineChart.png')

    # === BAR CHART: Total Wins ===
    bar_df = total_wins.reset_index()
    bar_df.columns = ['Team', 'Wins']

    fig_bar = px.bar(
        bar_df,
        x='Team',
        y='Wins',
        color='Team',  # ✅ Legend shows team names
        title='Total Wins by Team',
        labels={'Team': 'Team', 'Wins': 'Number of Wins'},
        color_discrete_map=color_map
    )

    # ✅ Remove legend
    fig_bar.update_layout(showlegend=False)

    fig_bar.write_json(f'{output_dir}/Total_Wins_Bar_Chart.json')
    fig_bar.write_image(f'{output_dir}/Total_Wins_Bar_Chart.png')

    print("CSV and visualizations have been generated successfully.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Analyze MLB team rivalry.")
    parser.add_argument("team1", help="First team code (e.g., 'nya')")
    parser.add_argument("team2", help="Second team code (e.g., 'bos')")
    parser.add_argument("start_year", type=int, help="Start year (e.g., 1995)")
    parser.add_argument("end_year", type=int, help="End year (e.g., 2004)")
    args = parser.parse_args()

    analyze_team_rivalry(args.team1.lower(), args.team2.lower(), args.start_year, args.end_year)

# Example usage in Terminal:
# python rivalry_tracker.py nya bos 1995 2004