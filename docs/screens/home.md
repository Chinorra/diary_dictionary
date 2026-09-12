# Home Screen

## Purpose

The Home Screen is the primary screen of the application and serves as the user's vocabulary notebook. It displays all words saved on a specific day and allows users to navigate between daily vocabulary pages.

---

## Layout

### Header

#### Drawer Button

* Located on the left side of the header.
* Opens the application drawer.

#### Date Display

* Located in the center of the header.
* Displays the currently selected date.
* Updates automatically when navigating between days.

---

### Body

The body contains a horizontal SlideTransition that behaves like flipping through notebook pages.

#### Daily Vocabulary Page

Each page represents a single day and contains:

* List of words added on that day.
* Empty state when no words exist for the selected day.

#### Navigation Between Days

* The app opens on today's page by default.
* Users can swipe left or right to navigate between existing days.
* Swiping is only allowed when the target day exists.
* Users cannot navigate to future dates.
* Users cannot navigate to dates that contain no saved vocabulary records.

#### Word List Item

Each word item may display:

* Word
* Pronunciation
* Short meaning
* Category (optional)

Tapping a word navigates to the Word Detail Screen.

---

### Bottom Navigation Bar

#### All Words

* Navigates to AllWordsScreen.
* Displays every saved word regardless of date.

#### Add New Word

* Center floating action button.
* Navigates to AddNewWordScreen.
* Allows users to search and save a new word.

#### Categories

* Navigates to CategoryScreen.
* Displays all vocabulary categories.

---

## Navigation

HomeScreen
├── Drawer
│   ├── SettingsScreen
│   ├── BackupScreen
│   └── AboutScreen
│
├── WordDetailScreen
│
├── AllWordsScreen
│
├── CategoryScreen
│
└── AddNewWordScreen

---

## Business Rules

### Initial State

* HomeScreen always opens on today's date.

### Daily Page Creation

* A day page exists only when at least one word is saved on that date.

### Page Navigation

* Users may navigate only to existing day pages.
* Users cannot navigate to future dates.
* Users cannot navigate to non-existent dates.

### Word Saving

When a new word is saved:

1. Save the word to the database.
2. Associate the word with today's date.
3. Update today's page immediately.
4. Create today's page if it does not already exist.

---

## Data Requirements

### Required Data

Date:

* Selected date
* Previous available date
* Next available date

Words:

* Word
* Meaning
* Pronunciation
* Category
* Created date

---

## Edge Cases

### First Launch

* No saved words exist.
* Display an empty notebook page for today.

### Missing Dates

Example:

2026-06-01 ✅
2026-06-02 ❌
2026-06-03 ✅

Swiping from June 1 should navigate directly to June 3.

### New Word Added

If today's page does not exist:

* Create the page.
* Display the newly added word immediately.

### Deleted Last Word Of A Day

If the last word on a day is removed:

* Remove the day page from navigation.

---

## Future Improvements

* Search words from HomeScreen.
* Calendar date picker.
* Word review mode.
* Daily learning statistics.
* Swipe animation resembling a real notebook.
