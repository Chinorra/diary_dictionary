# PROJECT_GUIDE.md

## 1. Project Overview

### Project Name

[My Dictionary]

### Purpose

Users can look up English words and automatically save them to a personal dictionary. Vocabulary is grouped by day, creating a notebook-like experience for reviewing and revisiting previously learned words.

### Target Users

* Students
* English learners
* Working professionals

### Platforms

* Android
* iOS

---

# 2. Tech Stack

## Frontend

* Flutter
* BLoC

## Backend

* Firebase
* REST API

## Local Database

* Drift

## Dependency Injection

* GetIt

## Network

* Dio
* Retrofit

## Analytics

* Firebase Analytics

---

# 3. Architecture

Architecture:

UI
→ Bloc
→ Interactor
→ Repository
→ DataSource
→ API / Database

Rules:

* UI never calls Repository directly
* Business logic belongs in Interactor
* Repository coordinates local and remote data
* Drift is source of truth whenever possible
* Keep UI dumb
* Avoid logic inside Widgets

---

# 4. User Flow

Launch App
→ Splash
→ Onboarding
→ Login
→ Home


# 5. Screen Specifications

---

## Splash Screen

### Purpose

Initial loading and app preparation.

### Features

* Initialize Firebase
* Load user session
* Load remote config
* Navigate to Login/Home

### Dependencies

* AuthRepository
* ConfigRepository

### Navigation

Splash
→ Login
→ Home

---

## Login Screen

### Purpose

Authenticate user.

### Features

* Email login
* Google login
* Forgot password
* Validation

### API

POST /login

### States

* Initial
* Loading
* Success
* Error

### Navigation

Login
→ Home
→ Register

---

## Home Screen

### Purpose

Main dashboard.

### Features

* Display user data
* Search
* Recent items
* Quick actions

### Components

* Search bar
* Banner carousel
* Category list
* Recent section

### Data Sources

* Local cache
* Remote API

### Navigation

Home
→ Detail
→ Search
→ Profile

---

## Detail Screen

### Purpose

Display full information of selected item.

### Features

* Load detail data
* Bookmark
* Share
* Download

### API

GET /detail/{id}

### States

* Loading
* Success
* Error

---

## Settings Screen

### Features

* Language
* Theme
* Notifications
* Logout

### Local Storage

* Preferences
* User settings

---

# 6. Feature Specifications

---

## Feature: Search

### Purpose

Allow users to search content.

### Inputs

* Keyword
* Filters

### Outputs

* Search results

### Edge Cases

* Empty query
* No results
* Network failure

### Cache Strategy

Store latest 20 searches.

---

## Feature: Bookmark

### Purpose

Save items for later.

### Storage

Drift

### Sync

Upload bookmarks after login.

---

# 7. Database Schema

## User

Fields:

* id
* name
* avatar
* email

Relationships:

* User -> Bookmarks

---

## Bookmark

Fields:

* id
* userId
* itemId
* createdAt

---

# 8. API Documentation

## Login

POST /login

Request:
{
email
password
}

Response:
{
token
user
}

---

## User Profile

GET /profile

Response:
{
id
name
avatar
}

---

# 9. State Management

Bloc

# 10. Coding Conventions

* Use feature-first structure
* One Bloc per feature
* Prefer immutable models
* Use Equatable
* Use const widgets whenever possible
* Keep methods under 100 lines
* Follow existing project patterns

---

# 11. Performance Requirements

* First launch < 3 seconds
* Home load < 1 second from cache
* API timeout = 30 seconds
* Image caching enabled

---

# 12. Security Requirements

* Store token securely
* Never log sensitive data
* Validate all API responses

---

# 13. Future Features

* Offline mode
* AI recommendations
* Social sharing

---

# 14. AI Agent Instructions

When modifying code:

* Read this document first
* Follow existing architecture
* Prefer minimal diffs
* Do not introduce new libraries without approval
* Reuse existing widgets and blocs
* Ask before changing database schema
* Ask before large refactors
