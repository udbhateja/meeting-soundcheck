#!/bin/bash

# ============================================
# meeting-soundcheck — Configuration
# Edit this file to customize your setup
# ============================================

# How many seconds before the meeting to play the sound
# Examples: 15 = 15 seconds, 60 = 1 minute, 300 = 5 minutes
LEAD_TIME_SECONDS=15

# How often to check for upcoming meetings (in seconds)
CHECK_INTERVAL=10

# Path to your custom sound file
# Leave empty to auto-detect from sounds/ folder
# Example: SOUND_FILE="/path/to/bbc-news-theme.mp3"
SOUND_FILE=""

# Only play sound for Microsoft Teams meetings?
# true  = only meetings with a Teams link
# false = all calendar meetings
TEAMS_ONLY=true
