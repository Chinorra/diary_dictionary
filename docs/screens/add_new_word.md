# Add New Word Screen

## Overview

The **Add New Word Screen** allows users to search for a new English word, retrieve its translation, definition, and example sentence from the dictionary API, edit the retrieved content, optionally add an image and category, and finally save the word to their diary.

The screen should prioritize a simple workflow:

1. Search for a word.
2. Select a suggested word.
3. Translate/fetch the word information.
4. Review and edit the definition and example.
5. Select a category.
6. Optionally add an image.
7. Save the word to the diary.

---

## Screen Layout

The screen contains the following sections:

```text
┌─────────────────────────────────────┐
│ Search word...                    🔍 │
├─────────────────────────────────────┤
│ Suggestions                         │
│   apple                             │
│   application                       │
│   apply                             │
├─────────────────────────────────────┤
│                         [Translate] │
│                                     │
│ Category                            │
│ ┌─────────────────────────────────┐ │
│ │ Select category              ▼  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Definition                          │
│ ┌─────────────────────────────────┐ │
│ │ A round fruit...                │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Example sentence                    │
│ ┌─────────────────────────────────┐ │
│ │ I ate an apple this morning.   │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Image                               │
│ ┌─────────────────────────────────┐ │
│ │          + Add Image            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │        Save to diary            │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

# 1. Word Search

At the top of the screen, provide a search bar.

### Requirements

* User can type a word.
* While typing, show a dropdown containing suggested words.
* Suggestions should contain the characters entered by the user.
* Suggestions should update as the user types.
* Tapping a suggestion sets that word as the selected/search word.
* The suggestion list should disappear when:

  * A suggestion is selected.
  * The user taps outside the search area.
  * The user submits the search.

### Example

If the user types:

```text
app
```

Suggestions could be:

```text
apple
application
apply
appointment
```

The search field should keep the selected word after the user chooses a suggestion.

---

# 2. Translate Button

Place a small **Translate** button below the search bar, aligned to the end of the row.

Example:

```text
Search word: apple

                         [Translate]
```

### Behavior

When the user taps **Translate**:

1. Validate that a word has been entered.
2. Call the dictionary API.
3. Parse the API response.
4. Extract the relevant definition and example sentence.
5. Populate the Definition field.
6. Populate the Example Sentence field.
7. Keep both fields editable.

The API should be called only when the user explicitly presses **Translate**.

### API

Use:

[Free Dictionary API](https://freedictionaryapi.com/?utm_source=chatgpt.com)

API integration should be isolated from the UI layer.

Recommended architecture:

```text
AddNewWordScreen
        ↓
AddNewWordCubit / Bloc
        ↓
DictionaryRepository
        ↓
DictionaryApiClient
        ↓
Free Dictionary API
```

---

# 3. Category

Add a category dropdown.

### Requirements

* User can select one category for the word.
* The selected category should be stored with the word.
* The dropdown should contain the categories defined by the application.
* Category selection is independent from the dictionary API.

Example:

```text
Category

┌─────────────────────────────────┐
│ Food                         ▼  │
└─────────────────────────────────┘
```

Possible categories:

```text
General
Food
Travel
Work
Technology
People
Nature
Other
```

The actual category list managed by the application, not retrieved from the dictionary API.

---

# 4. Definition

Provide an editable definition field.

### Requirements

* The field should be populated automatically after a successful Translate request.
* The user can modify the definition.
* The user can completely replace the API-provided definition.
* The definition should be stored in the database when the word is saved.

Example:

```text
Definition

┌─────────────────────────────────┐
│ A round fruit with red, green,  │
│ or yellow skin.                 │
└─────────────────────────────────┘
```

Use a multiline text input.

The API response should be treated as initial content only. User edits must not be overwritten unless the user presses **Translate** again.

---

# 5. Example Sentence

Provide an editable example sentence field.

### Requirements

* The field should be populated automatically after a successful Translate request when an example is available.
* The user can modify the sentence.
* The user can write their own example sentence.
* The final edited value should be saved to the database.

Example:

```text
Example sentence

┌─────────────────────────────────┐
│ I ate an apple this morning.   │
└─────────────────────────────────┘
```

Use a multiline text input.

If the API does not provide an example sentence, leave the field empty and allow the user to enter one manually.

---

# 6. Image

Add an optional image section.

### Requirements

* The user can add an image to the word.
* The image is optional.
* The user should be able to select an image from the device.
* Display the selected image as a preview.
* Allow the user to remove or replace the selected image.

Initial state:

```text
Image

┌─────────────────────────────────┐
│                                 │
│           + Add Image           │
│                                 │
└─────────────────────────────────┘
```

After selecting an image:

```text
Image

┌─────────────────────────────────┐
│                                 │
│          [Image Preview]        │
│                                 │
│       [Replace] [Remove]        │
└─────────────────────────────────┘
```

Image handling should be separated from the dictionary API because the API does not provide the user's personal diary image.

---

# 7. Save to Diary

At the bottom of the page, provide a primary action button:

```text
[ Save to diary ]
```

### Behavior

When the user taps **Save to diary**:

1. Validate the required fields.
2. Create a new word model.
3. Save the word to the local database.
4. Include:

   * Word
   * Definition
   * Example sentence
   * Category
   * Image, if selected
   * Created date
5. Return to the previous screen or show a successful save state.

Example data:

```text
Word:
apple

Definition:
A round fruit with red, green, or yellow skin.

Example:
I ate an apple this morning.

Category:
Food

Image:
optional

Created date:
2026-09-05
```

---

# User Flow

## Normal Flow

```text
Open Add New Word Screen
        ↓
Enter word
        ↓
Suggestion dropdown appears
        ↓
Select suggestion
        ↓
Tap Translate
        ↓
Call Free Dictionary API
        ↓
Populate definition + example
        ↓
User edits content if necessary
        ↓
Select category
        ↓
Optionally add image
        ↓
Tap Save to diary
        ↓
Save to database
        ↓
Return to diary
```

---

# API Loading State

While the Translate request is running:

```text
                         [Loading...]
```

The Translate button should be disabled while the request is in progress to prevent duplicate API requests.

Example state:

```text
Idle
 ↓
Translating
 ↓
Success
```

or

```text
Idle
 ↓
Translating
 ↓
Error
```

---

# API Error Handling

If the API request fails, do not clear existing user input.

Show an appropriate error message, for example:

```text
Unable to find this word.
Please check the spelling and try again.
```

Possible error cases:

* Empty search word.
* Word not found.
* Network unavailable.
* API error.
* Invalid API response.

The user should still be able to manually enter the definition and example sentence.

---

# Form Validation

Recommended required fields:

* Word
* Definition

Example sentence and image are optional.

Before saving:

```text
if word is empty
    show validation error

if definition is empty
    show validation error

otherwise
    save word
```

---

# State Management

The screen should not directly call the API.

Recommended responsibility separation:

```text
┌─────────────────────────┐
│ AddNewWordScreen        │
│                         │
│ UI only                 │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ AddNewWordBloc          │
│                         │
│ Screen state + actions  │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ DictionaryRepository    │
│                         │
│ Dictionary operations   │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ DictionaryApiClient     │
│                         │
│ HTTP/API communication  │
└─────────────────────────┘
```

The UI should react to states such as:

```text
initial
loading
success
error
```

For example:

```text
AddNewWordState
├── word
├── suggestions
├── selectedCategory
├── definition
├── example
├── image
├── status
└── errorMessage
```

---

# Important UX Rules

### 1. Do not automatically translate while typing

Typing should only update the suggestions.

```text
Typing
  ↓
Suggestions

Tap Translate
  ↓
API request
```

This avoids unnecessary API requests.

### 2. API data is editable

The dictionary API provides initial data only.

```text
API response
      ↓
Populate fields
      ↓
User can edit
      ↓
Save user's final version
```

### 3. Preserve user edits

If the user edits the definition or example, those values should remain unchanged until another explicit Translate action.

### 4. Disable duplicate requests

While translating:

```text
Translate button → disabled
```

### 5. Saving should not depend on API success

The user should be able to manually create a word even if the dictionary API is unavailable, as long as the required fields are filled.

---

# Acceptance Criteria

* [ ] User can enter a word in the search bar.
* [ ] Suggestions appear while typing.
* [ ] Suggestions contain the entered characters.
* [ ] User can select a suggestion.
* [ ] Translate button is displayed below the search bar.
* [ ] Translate calls Free Dictionary API.
* [ ] Definition is populated from the API response.
* [ ] Example sentence is populated from the API response when available.
* [ ] Definition is editable.
* [ ] Example sentence is editable.
* [ ] User can select a category.
* [ ] User can add an optional image.
* [ ] User can replace/remove the image.
* [ ] User can save the word to the diary.
* [ ] Word data is persisted in the database.
* [ ] API errors are handled gracefully.
* [ ] Loading state is displayed during API requests.
* [ ] Duplicate Translate requests are prevented.
* [ ] User input is not lost when the API fails.
* [ ] User can manually save a word without successful API translation.
