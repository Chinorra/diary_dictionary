# All Word Screen

## Overview

The **All Word Screen** displays all words saved by the user in their diary.

Words should be presented in **alphabetical order**, grouped by their first letter, giving the screen the appearance of a traditional dictionary.

The screen should use the existing shared `WordCard` widget:

```text
common/widget/word_card.dart
```

The screen should not implement a separate word-card UI.

---

# Screen Layout

The screen contains:

1. Header

   * Title: **All word**
   * Search icon on the right
2. Body

   * All saved words
   * Alphabetically sorted
   * Grouped by the first letter

Example:

```text
┌─────────────────────────────────────┐
│ All word                         🔍 │
├─────────────────────────────────────┤
│                                     │
│ A                                   │
│ ┌─────────────────────────────────┐ │
│ │ Word Card                       │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Word Card                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ B                                   │
│ ┌─────────────────────────────────┐ │
│ │ Word Card                       │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Word Card                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ C                                   │
│ ┌─────────────────────────────────┐ │
│ │ Word Card                       │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

---

# 1. Header

The header contains:

```text
All word                                      🔍
```

### Requirements

* Display the title **All word**.
* Display a search icon at the end of the header.
* Tapping the search icon should activate the word-search functionality.

The search UI can be implemented as an expandable search field or by navigating to a dedicated search state/screen.

The exact search UI implementation can be decided separately.

---

# 2. Word List

The body displays every word saved in the database.

Words must be sorted alphabetically based on the word itself.

For example, given:

```text
banana
apple
computer
application
book
```

The displayed order should be:

```text
A
apple
application

B
banana
book

C
computer
```

---

# 3. Alphabetical Sections

Words should be grouped according to their **first letter**.

Each section contains:

```text
A

WordCard
WordCard
WordCard
```

followed by:

```text
B

WordCard
WordCard
```

and so on.

### Example

```text
A

┌─────────────────────────────┐
│ apple                       │
│ A round fruit...            │
└─────────────────────────────┘

┌─────────────────────────────┐
│ application                 │
│ A program designed...       │
└─────────────────────────────┘


B

┌─────────────────────────────┐
│ banana                      │
│ A long curved fruit...      │
└─────────────────────────────┘
```

The letter header should appear **once per group**, not once per word.

---

# 4. Word Card

Use the existing shared widget:

```text
common/widget/word_card.dart
```

Do not recreate the WordCard UI inside `AllWordScreen`.

Example:

```dart
WordCard(
  word: word,
)
```

The exact constructor should follow the existing implementation of:

```text
common/widget/word_card.dart
```

`AllWordScreen` is responsible only for:

* Retrieving words.
* Sorting words.
* Grouping words.
* Passing each word to `WordCard`.

The visual representation of an individual word belongs to `WordCard`.

---

# 5. Data Flow

The screen should retrieve all saved words from the database through the application's existing architecture.

Recommended flow:

```text
AllWordScreen
      ↓
AllWordCubit / Bloc
      ↓
WordRepository
      ↓
Local Database
```

The UI should not directly access the database.

---

# 6. Sorting

Sort words alphabetically by their word value.

Example input:

```text
Zoo
apple
Banana
application
book
```

Normalize the words for comparison so that uppercase/lowercase differences do not affect ordering.

Expected result:

```text
A
apple
application

B
Banana
book

Z
Zoo
```

The original word capitalization should remain unchanged when displayed in `WordCard`.

---

# 7. Grouping

After sorting, group the words by their first alphabetic character.

Conceptually:

```text
Map<String, List<Word>>
```

Example:

```text
A → [apple, application]
B → [banana, book]
C → [computer]
```

Only create sections for letters that actually contain words.

For example, if the user has no words beginning with `D`, do not display:

```text
D
```

---

# 8. Search

The search icon allows the user to search through their saved words.

Search should filter the existing local word list.

Example:

```text
Search: app
```

Results:

```text
A

apple
application
```

Words that do not match the search query should not be displayed.

Search should preferably be performed locally because all saved words are already stored in the local database.

### Search behavior

* Search is case-insensitive.
* Search should match words containing the entered text.
* The alphabetical grouping should be recalculated after filtering.

Example:

```text
All words:

A
apple
application

B
banana

C
computer
```

Search:

```text
app
```

Result:

```text
A
apple
application
```

---

# 9. Empty State

If the user has not saved any words yet, display an appropriate empty state.

Example:

```text
┌─────────────────────────────────────┐
│ All word                         🔍 │
├─────────────────────────────────────┤
│                                     │
│                                     │
│          No words yet               │
│                                     │
│       Start adding new words        │
│       to your diary.                │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

The exact design can be decided during UI implementation.

---

# 10. Loading State

While the saved words are being loaded from the database, display a loading state.

Example:

```text
All word

Loading...
```

The screen should not attempt to sort or group the list until the data has been successfully loaded.

---

# 11. Error State

If loading the saved words fails, display an appropriate error state.

Example:

```text
Unable to load your words.

[ Try again ]
```

The user should be able to retry loading the data.

---

# 12. State Management

Recommended state structure:

```text
AllWordState
├── words
├── searchQuery
├── filteredWords
├── groupedWords
└── status
```

Possible status:

```text
initial
loading
success
error
```

Example:

```text
AllWordState
    ↓
Load all words
    ↓
Sort words
    ↓
Group words
    ↓
Display sections
```

When the search query changes:

```text
searchQuery changes
        ↓
Filter words
        ↓
Sort filtered words
        ↓
Group filtered words
        ↓
Update UI
```

---

# 13. Recommended Widget Structure

A possible widget structure:

```text
AllWordScreen
│
├── AppBar
│   ├── Title: "All word"
│   └── Search Icon
│
└── Body
    │
    └── ListView
        │
        ├── Section
        │   ├── Letter Header: A
        │   ├── WordCard
        │   └── WordCard
        │
        ├── Section
        │   ├── Letter Header: B
        │   ├── WordCard
        │   └── WordCard
        │
        └── Section
            ├── Letter Header: C
            └── WordCard
```

Avoid nesting a separate scrollable `ListView` inside each alphabet section.

Prefer one main scrollable list containing the section headers and `WordCard` widgets.

---

# User Flow

## Open All Word Screen

```text
Open All Word Screen
        ↓
Load saved words
        ↓
Sort alphabetically
        ↓
Group by first letter
        ↓
Display WordCards
```

## Search

```text
Tap search icon
        ↓
Enter search text
        ↓
Filter saved words
        ↓
Sort results
        ↓
Group results by first letter
        ↓
Display matching WordCards
```

---

# Architecture Responsibilities

### AllWordScreen

Responsible for:

* Rendering the UI.
* Displaying alphabet sections.
* Displaying `WordCard`.
* Handling user interaction.

### AllWordCubit / Bloc

Responsible for:

* Loading words.
* Managing search state.
* Filtering words.
* Sorting words.
* Grouping words.
* Managing loading/error states.

### WordRepository

Responsible for:

* Retrieving saved words.
* Interacting with the local database.

### WordCard

Responsible for:

* Rendering an individual word.

```text
AllWordScreen
      │
      ▼
AllWordCubit / Bloc
      │
      ▼
WordRepository
      │
      ▼
Local Database


AllWordScreen
      │
      ├── Section "A"
      │      ├── WordCard
      │      └── WordCard
      │
      ├── Section "B"
      │      ├── WordCard
      │      └── WordCard
      │
      └── Section "C"
             └── WordCard
```

---

# Important UX Rules

### 1. Dictionary-like appearance

The screen should visually resemble a dictionary:

```text
A
  apple
  application
  apply

B
  banana
  book

C
  computer
```

The alphabet letter acts as a section heading.

### 2. Alphabetical ordering

Always sort words alphabetically before displaying them.

### 3. No empty alphabet sections

Only display letters that have at least one saved word.

### 4. Reuse WordCard

Always use:

```text
common/widget/word_card.dart
```

Do not duplicate its UI implementation.

### 5. Local search

Search should operate on the user's saved words and should not require an API request.

### 6. Search does not modify saved data

Searching only filters the displayed list. It must not modify or delete words.

---

# Acceptance Criteria

* [ ] Header displays **All word**.
* [ ] Search icon is displayed at the end of the header.
* [ ] All saved words are loaded from the local database.
* [ ] Words are sorted alphabetically.
* [ ] Words are grouped by their first letter.
* [ ] Each alphabet letter appears only once per section.
* [ ] Empty alphabet sections are not displayed.
* [ ] Every word is displayed using `common/widget/word_card.dart`.
* [ ] Search can be activated from the search icon.
* [ ] Search is case-insensitive.
* [ ] Search matches words containing the search query.
* [ ] Search results remain alphabetically grouped.
* [ ] Search does not call the dictionary API.
* [ ] Empty state is displayed when there are no saved words.
* [ ] Loading state is displayed while loading words.
* [ ] Error state provides a retry action.
* [ ] UI does not access the database directly.
* [ ] Word sorting/grouping is handled outside the UI layer.
