# CLAUDE.md

## Project Overview

This project is a Flutter mobile application called **Diary Dictionary**.

The app is designed to help users learn and remember English vocabulary by turning their dictionary lookups into a personal daily vocabulary diary.

Users can:

- Search for English words.
- Retrieve word information from a dictionary API.
- Review and edit the definition.
- Add or edit their own example sentence.
- Assign a category to a word.
- Save words to their personal dictionary.
- View words learned on each day.
- Browse all saved words alphabetically.
- Organize and browse words by category.
- Navigate through previous days like pages in a diary.

The application should feel like a combination of:

- A personal English dictionary.
- A vocabulary notebook.
- A daily diary.

---

# Core User Flow

```text
Launch
  ↓
Splash
  ↓
Onboarding
  ↓
Login
  ↓
Home
```

Main application flow:

```text
Home
 ├── Previous / Next Day
 ├── All Words
 ├── Categories
 └── Add New Word
          ↓
      Search Word
          ↓
      Dictionary API
          ↓
      Edit Word Information
          ↓
      Save
          ↓
      Local Database
          ↓
      Home / All Words
```

---

# Main Screens

The application currently contains the following major screens:

```text
Splash Screen
Onboarding Screen
Login Screen
Home Screen
Add New Word Screen
All Word Screen
Category Screen
```

Additional screens can be introduced when required, but existing architecture and navigation conventions should be preserved.

---

# Product Concept

## Daily Vocabulary Diary

The main concept of the application is that vocabulary is associated with the day on which the user learned/saved it.

For example:
All Word Screen:

```text
September 10

A
apple
application

B
beautiful
```

in Home Screen,
the user can navigate to previous days:

```text
September 10
      ↓
September 9
      ↓
September 8
```

The Home screen behaves visually like a notebook/diary.

---

# Architecture

Use a layered architecture.

The preferred dependency direction is:

```text
Presentation
     ↓
State Management
     ↓
Interactor / Use Case
     ↓
Repository
     ↓
Data Source
     ↓
API / Local Database
```

Example:

```text
AddNewWordScreen
       ↓
AddNewWordCubit
       ↓
AddWordInteractor
       ↓
WordRepository
       ↓
DictionaryApi / LocalDatabase
```

---

# Layer Responsibilities

## Presentation

Presentation contains:

- Screens
- Widgets
- UI-specific models
- UI event handling

The presentation layer should not directly access:

- Database
- API clients
- Repository implementations

Example:

```dart
class AddNewWordScreen extends StatelessWidget {
  ...
}
```

---

## Bloc / Cubit

Use **Bloc/Cubit** for state management.

Cubit/Bloc is responsible for:

- Managing screen state.
- Handling user actions.
- Calling interactors/use cases.
- Exposing state to the UI.
- Handling loading/success/error states.

Do not put database or API implementation details inside Cubits.

Bad:

```dart
class AddWordCubit extends Cubit<State> {
  Future<void> saveWord() async {
    await database.insert(...);
  }
}
```

Preferred:

```text
Cubit
  ↓
Interactor
  ↓
Repository
  ↓
Database
```

---

# Interactor / Use Case

Interactors contain application/business operations.

Examples:

```text
SearchWordInteractor
SaveWordInteractor
GetWordsByDateInteractor
GetAllWordsInteractor
SearchSavedWordsInteractor
GetCategoriesInteractor
```

An interactor should represent a meaningful application action.

Example:

```dart
class SaveWordInteractor {
  final WordRepository repository;

  Future<void> call(Word word) {
    return repository.saveWord(word);
  }
}
```

Interactors should not contain UI code.

---

# Repository

Repositories abstract data access from the rest of the application.

Example:

```dart
abstract class WordRepository {
  Future<List<Word>> getAllWords();

  Future<List<Word>> getWordsByDate(DateTime date);

  Future<Word?> getWord(String word);

  Future<void> saveWord(Word word);

  Future<void> deleteWord(String id);
}
```

The repository decides whether data comes from:

- Local database
- Remote API
- Cache
- Other data sources

The UI should not care about the underlying data source.

---

# Data Sources

The project can contain separate data sources for different types of data.

Example:

```text
data/
├── remote/
│   └── dictionary_api/
│
└── local/
    └── database/
```

Remote data is primarily used for retrieving dictionary information.

Local data is the source of truth for the user's saved vocabulary.

---

# Local Database

The application needs persistent local storage for saved words.

The database should store at least:

```text
Word
 ├── id
 ├── word
 ├── definition
 ├── example
 ├── category
 ├── createdAt
 └── updatedAt
```

The exact schema should follow the existing database implementation.

Do not introduce another database technology without a clear reason.

---

# Dictionary API

The application uses a dictionary API to retrieve information about English words.

Primary API:

```text
https://freedictionaryapi.com/
```

The API is used when the user searches for a new word.

Typical flow:

```text
User enters word
      ↓
API request
      ↓
Dictionary response
      ↓
Parse response
      ↓
Display word information
      ↓
User edits information
      ↓
Save locally
```

The API should NOT be called when the user searches their already-saved words in the All Word screen.

Saved-word search should be local.

---

# Data Ownership

A clear distinction must be maintained:

## Remote API

Responsible for:

```text
Dictionary information
```

## Local Database

Responsible for:

```text
User's saved vocabulary
User-edited definitions
User-created examples
Categories
Dates
```

Once a word is saved, the user's local data should be treated as authoritative.

Do not overwrite user modifications with API data unless explicitly requested.

---

# Home Screen

The Home screen is the main screen of the application.

## Header

The header contains:

```text
┌─────────────────────────────────┐
│ ☰          September 12         │
└─────────────────────────────────┘
```

- Drawer/menu button on the left.
- Current selected date centered.

---

## Body

The body displays the words learned/saved for the selected date.

The screen should support horizontal/swipe navigation between available diary days.

Conceptually:

```text
       ← previous day

      September 12

      WordCard
      WordCard
      WordCard

       next day →
```

The Home screen uses a slide/page-style transition between dates.

The initial selected date should be today.

Users should only be able to navigate to dates that contain saved vocabulary, unless the product requirements are changed.

---

# Bottom Navigation

The main navigation contains:

```text
All Words
Categories
Add New Word
```

Conceptually:

```text
┌─────────────────────────────────┐
│                                 │
│             Content             │
│                                 │
├─────────────────────────────────┤
│ All Words   +Add Word   Category│
└─────────────────────────────────┘
```

The central Add New Word action should be visually emphasized according to the existing design.

---

# Add New Word Screen

The Add New Word screen allows users to search for a new English word and save it to their diary.

## Flow

```text
Enter word
    ↓
Search
    ↓
Dictionary API
    ↓
Display result
    ↓
Edit information
    ↓
Select category
    ↓
Save
```

---

## Search

The user enters a word into the search field.

While typing, the UI may display suggestions.

Search should support:

- Word input.
- Search action.
- Loading state.
- API error state.
- No-result state.

---

## Translate

The screen contains a small Translate action below/near the search area.

The exact translation implementation should follow the current product requirements and existing code.

Do not introduce a new translation API without discussing it first.

---

## Word Information

After a successful dictionary search, display information such as:

```text
Word

Definition

Example sentence

Category
```

The user must be able to edit appropriate fields before saving.

---

## Definition

The definition retrieved from the API should be editable.

The API response is only the initial value.

The user may change it before saving.

---

## Example Sentence

The example sentence should be editable.

The user should also be able to replace the API example with their own sentence.

The user's custom sentence must be preserved after saving.

---

## Category

The user can select a category for the word.

Categories should be represented consistently across the application.

Do not create duplicate category representations in different screens.

---

## Save

When the user saves:

```text
Add New Word Screen
        ↓
Validate input
        ↓
Save Word Interactor
        ↓
Word Repository
        ↓
Local Database
```

After successful saving:

- Show appropriate success feedback.
- Return/navigate to the appropriate screen.
- The new word should appear on the correct diary date.
- The word should appear in All Words.
- The word should appear in its selected category.

---

# All Word Screen

The All Word Screen displays all saved vocabulary.

The design should resemble a traditional dictionary.

Example:

```text
All word                                      🔍

A

WordCard
WordCard

B

WordCard
WordCard

C

WordCard
```

---

## Sorting

Words must be sorted alphabetically.

Sorting should be case-insensitive.

Example:

```text
Zoo
apple
Banana
application
book
```

Should become:

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

Original capitalization should remain unchanged when displayed.

---

## Grouping

Words are grouped by their first alphabetic character.

Conceptually:

```dart
Map<String, List<Word>>
```

Example:

```text
A → [apple, application]
B → [banana, book]
C → [computer]
```

Do not display empty alphabet sections.

---

## WordCard

Always reuse:

```text
common/widget/word_card.dart
```

Do not duplicate the WordCard UI inside another screen.

The screen is responsible for:

```text
Load
Sort
Group
Display
```

The WordCard is responsible for:

```text
Display one word
```

---

## Search

All Word search is local.

Flow:

```text
Tap search
      ↓
Enter query
      ↓
Filter saved words
      ↓
Sort
      ↓
Group
      ↓
Display results
```

Search should:

- Be case-insensitive.
- Match words containing the query.
- Not call the dictionary API.
- Not modify saved data.

---

# Category Screen

The Category Screen displays saved vocabulary organized by category.

The category system should use the same category model/data source used by Add New Word.

Do not duplicate category definitions between screens.

Possible structure:

```text
Categories

┌─────────────────────────────────┐
│  Animal                         │
│                                 │
│                                 │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Food                           │
│                                 │
│                                 │
└─────────────────────────────────┘
```

The exact UI can evolve independently from the underlying category model.

---

# Shared Widgets

Reusable widgets should live in the shared/common widget area.

For example:

```text
common/
└── widget/
    └── word_card.dart
```

Before creating a new widget, check whether an existing reusable widget already provides the required functionality.

Prefer:

```text
Reuse existing widget
```

over:

```text
Create a visually similar duplicate
```

---

# UI Principles

The application should have a consistent visual language.

Follow the existing:

- Theme
- Typography
- Spacing
- Colors
- Border radius
- Buttons
- Input fields
- Animations
- Shared widgets

Do not introduce arbitrary styles when an existing project style can be reused.

Avoid hardcoding design values when project constants/theme values already exist.

---

# Navigation

Navigation should be centralized according to the existing project architecture.

Do not add navigation logic directly throughout random widgets.

Before introducing a new route:

1. Check existing navigation.
2. Follow the existing route naming convention.
3. Reuse existing navigation utilities.
4. Keep navigation consistent with the rest of the application.

---

# State Management Rules

Use immutable states where possible.

Prefer explicit states such as:

```text
Initial
Loading
Success
Error
```

For screens with multiple independent states, use a well-defined state model rather than multiple loosely related boolean variables.

Avoid:

```dart
bool isLoading;
bool hasError;
bool isSuccess;
```

when a clear state model can represent the same information.

---

# Error Handling

Errors should be handled at the appropriate layer.

Example:

```text
API Error
    ↓
Repository / Data Source
    ↓
Interactor
    ↓
Cubit
    ↓
UI Error State
```

Do not expose raw API/database implementation details directly to the UI.

User-facing errors should be understandable.

Avoid displaying raw exceptions such as:

```text
SocketException: Failed host lookup...
```

unless the existing application explicitly requires technical error output.

---

# Loading States

Every asynchronous operation that can take noticeable time should have an appropriate loading state.

Examples:

```text
Search word
Loading
```

```text
Load saved words
Loading
```

```text
Save word
Saving...
```

Avoid allowing users to accidentally trigger the same destructive/expensive operation multiple times while it is already running.

---

# Database Rules

When modifying the database:

1. Check the current schema first.
2. Do not recreate existing tables unnecessarily.
3. Preserve existing user data.
4. Add migrations when required.
5. Update generated database code when required by the database technology.
6. Test database changes.

Never silently delete or reset user data to make a schema change work.

---

# API Rules

When working with the dictionary API:

- Keep API models separate from domain models where appropriate.
- Do not expose raw API response objects throughout the UI.
- Handle missing fields safely.
- Handle empty definitions/examples safely.
- Handle network errors.
- Handle malformed responses.
- Do not assume every dictionary result has the same structure.

---

# Models

Keep models focused on their layer.

A typical structure can be:

```text
Data Model
    ↓
Mapping
    ↓
Domain Model
    ↓
Presentation
```

Avoid using API response models directly inside widgets when a domain model is more appropriate.

---

# Date Handling

Dates are important because vocabulary belongs to a diary day.

Be careful when comparing dates.

When determining whether two words belong to the same diary day, compare the relevant calendar date rather than blindly comparing full timestamps.

For example:

```text
2026-09-12 09:00
2026-09-12 21:00
```

belong to the same diary day.

Do not use exact timestamp equality to determine daily grouping.

Consider timezone behavior when implementing date-based queries.

---

# Search Rules

There are two different types of search in the application.

## Dictionary Search

Used by:

```text
Add New Word
```

Purpose:

```text
Find information about a new word
```

Source:

```text
Remote Dictionary API
```

## Saved Word Search

Used by:

```text
All Word
```

Purpose:

```text
Find words already saved by the user
```

Source:

```text
Local Database
```

Never mix these two responsibilities.

---

# Performance

The application should remain responsive when the user's vocabulary grows.

Avoid:

- Unnecessary API requests.
- Rebuilding the entire screen for unrelated state changes.
- Repeated database queries inside `build()`.
- Nested scrollable lists when a single list can be used.
- Expensive sorting/grouping directly inside frequently rebuilding widgets.

For example, the All Word screen should prepare:

```text
Filter
  ↓
Sort
  ↓
Group
```

outside the individual WordCard widgets.

---

# Widget Performance

Use appropriate Flutter performance techniques.

Prefer:

```dart
const
```

where possible.

Avoid creating expensive objects repeatedly inside `build()`.

Use keys where list item identity matters.

For large lists, use efficient builders such as:

```dart
ListView.builder
```

or an equivalent lazy list implementation.

---

# Testing

Important business logic should be unit tested.

Examples:

```text
Word sorting
Word grouping
Word filtering
Date grouping
Category filtering
Word mapping
Repository behavior
Interactor behavior
```

UI behavior should be tested where it provides meaningful confidence.

Example:

```text
Search word
Display loading
Display error
Save word
Display saved word
```

Do not write tests purely for coverage numbers.

Tests should verify meaningful behavior.

---

# Code Style

Follow the existing Dart/Flutter style in the project.

Prefer:

```dart
final
const
immutable state
small focused methods
meaningful names
```

Avoid:

```text
Huge widgets
Huge Cubits
Duplicated logic
Magic numbers
Unnecessary abstraction
```

Keep methods focused on one responsibility.

---

# File Organization

Follow the existing project structure.

A conceptual structure is:

```text
lib/
├── common/
│   └── widget/
│       └── word_card.dart
│
├── data/
│   ├── local/
│   └── remote/
│
├── domain/
│   ├── model/
│   ├── repository/
│   └── interactor/
│
├── presentation/
│   ├── home/
│   ├── add_new_word/
│   ├── all_word/
│   └── category/
│
└── ...
```

Do not reorganize the entire project unless there is a clear reason.

Follow the actual existing project structure when it differs from this conceptual structure.

---

# Dependency Injection

Use the project's existing dependency injection mechanism.

Do not instantiate repositories, API clients, databases, or interactors directly inside screens.

Preferred:

```text
DI Container
    ↓
Repository
    ↓
Interactor
    ↓
Cubit
```

Follow existing project conventions such as `getIt`/`injector` if already established.

---

# Localization

All user-facing strings should be localized according to the project's existing localization system.

Do not hardcode user-facing text directly into widgets if localization is already configured.

Examples:

```text
All word
Search
Save
Definition
Example
Category
No words yet
Try again
```

Use the existing generated localization API and follow the project's localization conventions.

---

# Images and Assets

Before adding a new asset:

1. Check whether an existing asset can be reused.
2. Follow the existing asset directory structure.
3. Register assets correctly in `pubspec.yaml`.
4. Avoid unnecessary duplicate assets.

---

# Animations

Animations are part of the application's diary/notebook experience.

Existing or planned animations include:

- Day-to-day slide transitions.
- Page-like navigation.
- Screen transitions.

Animations should:

- Feel smooth.
- Avoid unnecessary complexity.
- Respect Flutter performance.
- Follow the existing design.

Do not add animations simply for decoration if they make interaction slower or confusing.

---

# Important Product Rules

These rules should always be respected.

### Rule 1 — Local data belongs to the user

User-edited definitions and examples must not be unexpectedly overwritten by API data.

### Rule 2 — Saved words work offline

Browsing previously saved words should not require the dictionary API.

### Rule 3 — Dictionary API is for lookup

The remote API is primarily for retrieving information about new words.

### Rule 4 — Reuse shared components

Use existing shared widgets such as:

```text
common/widget/word_card.dart
```

instead of recreating equivalent components.

### Rule 5 — Keep layers separated

Do not let:

```text
Screen → Database
Screen → API
```

Instead:

```text
Screen
  ↓
Cubit
  ↓
Interactor
  ↓
Repository
  ↓
Data Source
```

### Rule 6 — Preserve existing behavior

When implementing a new feature, avoid changing unrelated functionality.

---

# Working With This Project

When asked to implement a feature:

## Step 1 — Understand the existing code

Before modifying code:

- Inspect the relevant screen.
- Inspect its Cubit/Bloc.
- Inspect related models.
- Inspect repository/interactor implementations.
- Inspect existing shared widgets.
- Inspect navigation.
- Inspect dependency injection.

Do not immediately create new files.

---

## Step 2 — Reuse existing patterns

Look for an existing implementation that solves a similar problem.

For example:

```text
Existing search screen
Existing Bloc
Existing repository
Existing form
Existing WordCard
Existing database query
```

Reuse established patterns whenever possible.

---

## Step 3 — Make the smallest reasonable change

Prefer:

```text
Small focused changes
```

over:

```text
Large refactors
```

Do not refactor unrelated code while implementing a feature unless the refactor is necessary.

---

## Step 4 — Validate

After implementation:

```text
flutter analyze
```

Run relevant tests:

```text
flutter test
```

If possible, test the affected screen manually.

---

# Claude Code Behavior

When working on this project, Claude should:

1. Read relevant existing code before making architectural decisions.
2. Follow existing project conventions.
3. Reuse existing widgets and utilities.
4. Prefer minimal diffs.
5. Avoid unnecessary refactoring.
6. Keep presentation, domain, and data responsibilities separated.
7. Avoid introducing new dependencies unless necessary.
8. Explain important architectural decisions.
9. Run analysis/tests after meaningful changes.
10. Never silently remove existing functionality.
11. Never reset or delete user data to solve implementation problems.
12. Ask for clarification when a product requirement is genuinely ambiguous rather than making a large assumption.

---

# Before Creating a New File

Ask:

```text
Does this functionality already exist?
```

Then:

```text
Can an existing class/widget/interactor/repository be reused?
```

Only create a new file when it provides a clear responsibility.

---

# Before Adding a Dependency

Ask:

```text
Can Flutter or the existing project already solve this?
```

If not, consider whether an existing dependency can be reused.

Do not add packages for trivial functionality.

Before adding a package, consider:

- Maintenance.
- Compatibility with the current Flutter version.
- Package quality.
- Whether the functionality is actually necessary.

---

# Definition of Done

A feature is considered complete when:

- [ ] The feature matches the requested behavior.
- [ ] Existing architecture is respected.
- [ ] Existing shared widgets are reused.
- [ ] UI states are handled.
- [ ] Error states are handled.
- [ ] Loading states are handled.
- [ ] User data is preserved.
- [ ] Relevant business logic has tests.
- [ ] `flutter analyze` passes.
- [ ] Relevant tests pass.
- [ ] No unnecessary dependencies were introduced.
- [ ] No unrelated files were changed.

---

# Current Feature Documentation

Detailed feature requirements are maintained in separate markdown files.

For example:

```text
docs/
├── add_new_word_screen.md
├── all_word_screen.md
└── ...
```

Before implementing a feature, Claude should read its corresponding specification file.

The feature specification describes:

- UI requirements.
- User flow.
- Business behavior.
- State management expectations.
- Acceptance criteria.

`CLAUDE.md` defines the **global project rules**.

Feature-specific markdown files define the **specific behavior of each feature**.

When there is a conflict:

```text
Current codebase constraints
        ↓
Feature-specific requirements
        ↓
CLAUDE.md general conventions
```

Use judgment and explicitly explain important conflicts.

---

# Golden Rule

> **Build the simplest solution that fits the existing architecture, preserves user data, follows the product requirements, and is easy for another Flutter developer to maintain.**
