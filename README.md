# MatchKeeper

A SwiftUI-based iOS application that allows users to search for soccer matches, watch highlights, and document their personal thoughts and experiences for each match.

---

## Overview

This app combines match discovery with personal journaling. Users can search for matches via an external API, view match details (including embedded YouTube highlights), and save their own reflections. Saved matches appear on the home screen as a personalized collection.

---

## Features

* **Search Matches**
  Search for soccer matches using an external API.

* **Match Detail View**
  View match information and watch highlight videos.

* **Journal Entries**
  Add and edit a personal journal entry for each match.

* **Save Matches**
  Matches with journal entries are saved and displayed on the home screen.

* **My Matches Feed**
  View all saved matches in one place, along with journal previews.

---

## Tech Stack

* **Swift**
* **SwiftUI**
* **MVVM Architecture**
* **YouTube Embed (WKWebView)**
* **REST API Integration**

---

## Architecture

The app follows a simple MVVM-style structure:

* **Models**

  * `Match`: Represents a soccer match, including optional journal text.

* **ViewModels / Data Layer**

  * `DataManager`: Handles state management, match storage, and journal updates.

* **Views**

  * Home View (My Matches)
  * Search View
  * Match Detail View

---

## Data Flow

1. User searches for matches via API
2. Selects a match → navigates to detail view
3. Adds journal entry and saves
4. `DataManager` updates the match’s `journalText`
5. Home view displays saved matches

---

## Getting Started

### Prerequisites

* Xcode (latest version recommended)
* iOS Simulator or physical device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   ```

2. Open the project in Xcode:

   ```bash
   open YourProject.xcodeproj
   ```

3. Run the app on a simulator or device.

---

