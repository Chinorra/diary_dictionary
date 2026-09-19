# Category Screen

## Overview

The **Category Screen** displays all available word categories.

Each category is represented as a large selectable category card.

When the user taps a category, navigate to the **Single Category Screen**, which displays all saved words belonging to that category.

The main flow is:

```text
Category Screen
       ↓
Select Category
       ↓
Single Category Screen
       ↓
Display Words in Selected Category
```

---

# Screen Layout

The screen contains:

1. Header
   - Title: **Categories**

2. Body
   - List of category cards

Example:

```text
┌─────────────────────────────────────┐
│ Categories                          │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Animal                          │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Food                            │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Travel                          │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Technology                      │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

# 1. Header

Display a header with the title:

```text
Categories
```

The header should follow the existing application's design system.

Reuse:

- Existing app bar patterns.
- Typography.
- Colors.
- Spacing.
- Theme values.

Do not introduce a separate visual style for this screen.

---

# 2. Category List

The body displays all available categories.

Each category should be displayed as a large tappable card.

Example:

```text
┌─────────────────────────────────┐
│                                 │
│  Animal                         │
│                                 │
│                                 │
└─────────────────────────────────┘
```

Each category card should:

- Display the category name.
- Be clearly tappable.
- Follow the application's existing card design.
- Have consistent spacing between cards.

The category list should be scrollable when necessary.

---

# 3. Category Card

Each category should be represented by a reusable widget if one already exists.

Conceptually:

```text
CategoryCard
```

Example:

```text
┌─────────────────────────────────┐
│ Animal                          │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Food                            │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Travel                          │
└─────────────────────────────────┘
```

The `CategoryScreen` should be responsible for displaying the category list.

The individual category UI should belong to the reusable category card widget.

Do not create duplicated category card UI in multiple places.

---

# 4. Select Category

When the user taps a category:

```text
Tap "Animal"
        ↓
Navigate
        ↓
SingleCategoryScreen
        ↓
Display words in "Animal"
```

The selected category should be passed through navigation using the existing navigation architecture.

For example, conceptually:

```text
CategoryScreen
       ↓
Selected Category
       ↓
SingleCategoryScreen(category)
```

The destination screen should know which category is currently selected.

---

# 5. Empty Categories

A category may not contain any saved words.

Categories should still be displayed on the Category Screen even if they currently contain zero words.

For example:

```text
Animal

Food

Travel

Technology
```

Even if:

```text
Technology → 0 words
```

the user should still be able to select it.

The empty state will be handled inside `SingleCategoryScreen`.

---

# 6. Category Data

The category list should use the same category source/model as the rest of the application.

Categories must remain consistent between:

```text
Add New Word Screen
        ↓
Category Selection

Category Screen
        ↓
Category List

Single Category Screen
        ↓
Filter Words by Category
```

Do not define separate category lists in different screens.

There should be a single source of truth for categories.

---

# 7. Data Flow

Recommended flow:

```text
CategoryScreen
       ↓
CategoryCubit / Bloc
       ↓
GetCategoriesInteractor
       ↓
CategoryRepository
       ↓
Data Source
```

The UI should not directly access the database.

If categories are static application data rather than database entities, follow the existing project architecture for managing static data.

---

# 8. Loading State

If categories need to be loaded asynchronously, display an appropriate loading state.

Example:

```text
Categories

Loading...
```

If categories are static and immediately available, a loading state may not be necessary.

Follow the existing application pattern.

---

# 9. Error State

If category loading fails, display an appropriate error state.

Example:

```text
Unable to load categories.

[ Try again ]
```

Do not expose raw technical exceptions directly to the user.

---

# 10. Navigation

Navigation flow:

```text
Category Screen
       │
       ├── Animal
       │      ↓
       │   Single Category Screen
       │
       ├── Food
       │      ↓
       │   Single Category Screen
       │
       ├── Travel
       │      ↓
       │   Single Category Screen
       │
       └── Technology
              ↓
           Single Category Screen
```

The destination screen should receive the selected category.

---

# State Management

Recommended state:

```text
CategoryState
├── categories
└── status
```

Possible status:

```text
initial
loading
success
error
```

The selected category does not necessarily need to remain in the `CategoryScreen` state after navigation.

It can be passed directly to the destination screen according to the existing navigation architecture.

---

# Architecture Responsibilities

## CategoryScreen

Responsible for:

- Rendering the category list.
- Displaying loading/error states.
- Handling category selection.
- Triggering navigation.

## CategoryCubit / Bloc

Responsible for:

- Loading categories.
- Managing category screen state.

## Category Repository

Responsible for:

- Providing category data.

## Category Card

Responsible for:

- Displaying one category.
- Handling the visual tap interaction.

---

# Important UX Rules

### 1. One source of truth for categories

The category definitions used in:

```text
Add New Word
Category Screen
Single Category Screen
```

must be consistent.

Do not create separate hardcoded lists for each screen.

---

### 2. Categories remain visible

Categories should still be displayed even when they contain no words.

The purpose of this screen is to browse available categories, not only categories that currently contain data.

---

### 3. Simple navigation

Tapping a category should immediately navigate to the selected category.

Avoid unnecessary confirmation dialogs.

---

### 4. Reuse existing design

Follow existing:

- Cards.
- Theme.
- Typography.
- Spacing.
- Navigation.
- Animation patterns.

---

# Acceptance Criteria

- [ ] Header displays **Categories**.
- [ ] All available categories are displayed.
- [ ] Each category is displayed as a tappable card.
- [ ] Category cards have consistent spacing.
- [ ] Category list is scrollable when necessary.
- [ ] Categories use the same data source/model across the application.
- [ ] Tapping a category navigates to `SingleCategoryScreen`.
- [ ] The selected category is passed to the destination screen.
- [ ] Categories can be displayed even when they contain zero words.
- [ ] Loading state is handled when applicable.
- [ ] Error state provides a retry action when applicable.
- [ ] UI does not directly access the database.
- [ ] Existing project architecture and navigation patterns are respected.
