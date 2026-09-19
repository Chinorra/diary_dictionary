# Single Category Screen

## Overview

The **Single Category Screen** displays all saved words belonging to one selected category.

The UI and behavior should be similar to the **All Word Screen**.

The main difference is:

```text
All Word Screen
    ↓
Display all saved words

Single Category Screen
    ↓
Display only words from the selected category
```

Words should:

* Belong to the selected category.
* Be sorted alphabetically.
* Be grouped by their first letter.
* Be displayed using the existing `WordCard` widget.

The screen should reuse:

```text
common/widget/word_card.dart
```

Do not recreate the WordCard UI.

---

# Screen Layout

Example when the selected category is **Animal**:

```text
┌─────────────────────────────────────┐
│ ←  Animal                        🔍 │
├─────────────────────────────────────┤
│                                     │
│ A                                   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ WordCard: ant                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ WordCard: ape                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ B                                   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ WordCard: bear                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ C                                   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ WordCard: cat                   │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

The screen contains:

1. Header

   * Back button.
   * Selected category name.
   * Search icon.
2. Body

   * Words belonging to the selected category.
   * Alphabetical sections.
   * `WordCard` for every word.

---

# 1. Header

The header should display:

```text
←  Animal                         🔍
```

Requirements:

* Back button at the start.
* Selected category name as the title.
* Search icon at the end.

Example:

```text
←  Food                           🔍
```

Tapping the back button returns to:

```text
CategoryScreen
```

The search icon activates search functionality for words inside the currently selected category.

---

# 2. Load Words by Category

The screen should load only words belonging to the selected category.

Example:

```text
Selected category:
Animal
```

Saved words:

```text
apple → Food
ant → Animal
banana → Food
bear → Animal
cat → Animal
```

Displayed words:

```text
Animal

A
ant

B
bear

C
cat
```

Words belonging to other categories must not be displayed.

---

# 3. Alphabetical Sorting

Words in the selected category must be sorted alphabetically.

Sorting should be case-insensitive.

Example input:

```text
Cat
ant
Bear
ape
```

Expected display:

```text
A
ant
ape

B
Bear

C
Cat
```

Original capitalization should remain unchanged when displayed.

---

# 4. Alphabetical Grouping

After filtering and sorting, group words by their first letter.

Example:

```text
Animal

A
ant
ape

B
bear

C
cat
```

Conceptually:

```text
Map<String, List<Word>>
```

Example:

```text
A → [ant, ape]
B → [bear]
C → [cat]
```

Only display letters that contain at least one word.

Do not display empty sections.

---

# 5. Word Card

Every word must use the existing shared widget:

```text
common/widget/word_card.dart
```

Conceptually:

```dart
WordCard(
  word: word,
)
```

The exact constructor should follow the existing implementation.

`SingleCategoryScreen` is responsible for:

```text
Load
Filter
Sort
Group
Display
```

`WordCard` is responsible for:

```text
Display one word
```

Do not duplicate the WordCard UI.

---

# 6. Search

The search functionality should search only within the currently selected category.

Example:

```text
Selected category:
Animal
```

Words:

```text
ant
ape
bear
cat
```

Search:

```text
a
```

Result:

```text
A
ant
ape

B
bear

C
cat
```

Search:

```text
an
```

Result:

```text
A
ant
```

Words from other categories must never appear in search results.

---

# 7. Search Behavior

Search should:

* Be case-insensitive.
* Match words containing the search query.
* Filter only the selected category.
* Recalculate alphabetical sections after filtering.
* Not modify saved data.
* Not call the dictionary API.

Search flow:

```text
Tap Search
      ↓
Enter Query
      ↓
Filter Category Words
      ↓
Sort Results
      ↓
Group by First Letter
      ↓
Display WordCards
```

---

# 8. Empty State

If the selected category does not contain any words, display an empty state.

Example:

```text
← Technology

No words in this category yet.

Start adding new words to your diary.
```

The category itself still exists.

An empty category does not mean the category should be removed.

---

# 9. Empty Search State

If the user searches for a word but there are no matching results:

```text
No matching words found.
```

Example:

```text
Category:
Animal

Search:
dog
```

If there is no matching word:

```text
No matching words found.
```

This state is different from an empty category.

---

# 10. Loading State

While words are loading:

```text
Animal

Loading...
```

The loading state should follow the existing application UI pattern.

---

# 11. Error State

If words cannot be loaded:

```text
Unable to load words.

[ Try again ]
```

The retry action should reload words for the currently selected category.

---

# 12. Data Flow

Recommended architecture:

```text
SingleCategoryScreen
          ↓
SingleCategoryCubit / Bloc
          ↓
GetWordsByCategoryInteractor
          ↓
WordRepository
          ↓
Local Database
```

The screen should not directly access the database.

---

# 13. State Management

Recommended state:

```text
SingleCategoryState
├── category
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

Flow:

```text
Open Screen
      ↓
Receive Category
      ↓
Load Words by Category
      ↓
Sort Words
      ↓
Group Words
      ↓
Display UI
```

When searching:

```text
Search Query Changes
        ↓
Filter Category Words
        ↓
Sort Results
        ↓
Group Results
        ↓
Update UI
```

---

# 14. Recommended Widget Structure

```text
SingleCategoryScreen
│
├── AppBar
│   ├── Back Button
│   ├── Category Title
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
        │   └── WordCard
        │
        └── Section
            ├── Letter Header: C
            └── WordCard
```

Use one main scrollable list.

Avoid nesting multiple scrollable lists.

---

# Architecture Responsibilities

## SingleCategoryScreen

Responsible for:

* Rendering the UI.
* Displaying the selected category.
* Displaying alphabet sections.
* Displaying `WordCard`.
* Handling user interactions.

## SingleCategoryCubit / Bloc

Responsible for:

* Loading words for the selected category.
* Managing search state.
* Filtering words.
* Sorting words.
* Grouping words.
* Managing loading/error states.

## GetWordsByCategoryInteractor

Responsible for:

```text
Get all words belonging to one category.
```

## WordRepository

Responsible for retrieving the required data from the local database.

## WordCard

Responsible for displaying one individual word.

---

# Relationship With All Word Screen

The `SingleCategoryScreen` has similar behavior to `AllWordScreen`.

Conceptually:

```text
AllWordScreen
      ↓
Get all words
      ↓
Sort
      ↓
Group
      ↓
Display
```

While:

```text
SingleCategoryScreen
      ↓
Get words by selected category
      ↓
Sort
      ↓
Group
      ↓
Display
```

The UI and reusable logic should be shared where appropriate.

Do not duplicate complex sorting, grouping, or search logic if an existing reusable solution can support both screens.

For example, shared logic may be responsible for:

```text
Filter words
Sort words
Group words by first letter
```

Then each screen provides a different source of words:

```text
AllWordScreen
    → All saved words

SingleCategoryScreen
    → Words from selected category
```

---

# Important UX Rules

### 1. Only show selected category words

Never display words from another category.

### 2. Same dictionary experience

The screen should feel consistent with the All Word screen.

Use:

* Same WordCard.
* Same alphabetical grouping.
* Same sorting behavior.
* Same search behavior.
* Same empty/loading/error patterns.

### 3. Local search only

Searching saved words should not call the dictionary API.

### 4. No empty alphabet sections

Only display letters that contain words.

### 5. Preserve navigation context

The selected category should remain clear in the screen title.

Example:

```text
← Animal                         🔍
```

---

# Acceptance Criteria

* [ ] Screen receives the selected category.
* [ ] Header displays the selected category name.
* [ ] Back button returns to `CategoryScreen`.
* [ ] Search icon is displayed.
* [ ] Only words belonging to the selected category are loaded.
* [ ] Words are sorted alphabetically.
* [ ] Sorting is case-insensitive.
* [ ] Words are grouped by their first letter.
* [ ] Empty alphabet sections are not displayed.
* [ ] Every word uses `common/widget/word_card.dart`.
* [ ] Search only searches within the selected category.
* [ ] Search is case-insensitive.
* [ ] Search does not call the dictionary API.
* [ ] Search does not modify saved data.
* [ ] Empty category state is handled.
* [ ] Empty search result state is handled.
* [ ] Loading state is handled.
* [ ] Error state provides a retry action.
* [ ] UI does not directly access the database.
* [ ] Existing project architecture is respected.
* [ ] Sorting/grouping/search logic is reused with `AllWordScreen` when appropriate.
