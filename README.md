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
