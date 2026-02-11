# MLB Rivalry Tracker

This Python app uses `mlbstatsapi` to analyze and visualize MLB rivalries between any two teams over a custom year range.

## Features

- Pulls game data using MLB Stats API
- Analyzes win/loss trends
- Visualizes rivalry dynamics

## How to Run

1. Clone this repo

2. Create Virtual Environment

   `python -m venv venv`
3. Activate Virtual Environment

   `venv\Scripts\activate`
4. Install Requirements

   `pip install -r requirements.txt`
5. Run program with two team codes and a range of years (see team code list below)

   `python rivalry_tracker.py nya bos 1995 2004`


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
