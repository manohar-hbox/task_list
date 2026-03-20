# Flutter Task List App

A Flutter mobile application that interfaces with the JSONPlaceholder API to manage a simple task list. This project demonstrates BLoC pattern implementation, RESTful API integration, and offline support with optimistic updates.

## Setup Instructions

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd task_list
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate Hive adapters**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```

## Design Decisions & Assumptions

- **Mock Login**: A simple login screen is implemented with hardcoded credentials (`admin`/`password`). This is used to demonstrate basic authentication flow and state management.
- **State Management**: The app uses the **BLoC (Business Logic Component) pattern** with the `flutter_bloc` library. This ensures a clean separation of concerns between UI and business logic.
- **Local Storage**: **Hive** is used for local caching due to its performance and ease of use with Flutter.
- **Offline Support**: The app implements **optimistic updates**. When a user adds, updates, or deletes a task, the change is immediately reflected in the UI and saved to the local database. A background sync mechanism (manual or automatic on reconnection) is used to sync these changes with the API.

## BLoC Pattern Implementation

- **TaskBloc**: Manages the state of the task list.
    - **Events**: `LoadTasks`, `AddTask`, `ToggleTaskCompletion`, `DeleteTask`, `SearchTasks`, `SyncTasks`.
    - **States**: `TaskInitial`, `TaskLoading`, `TaskLoaded`, `TaskError`.
- **AuthBloc**: Manages the authentication state.
    - **Events**: `LoginRequested`, `LogoutRequested`.
    - **States**: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`.

The UI uses `BlocBuilder` and `BlocListener` to react to state changes and rebuild accordingly.

## Offline Support Strategy

1.  **Caching**: All tasks fetched from the API are cached locally using Hive. If the user is offline, the app loads data from the local cache.
2.  **Optimistic Updates**: Changes (add/toggle/delete) are applied to the local state immediately.
3.  **Tracking Local Changes**: Tasks created offline are marked with `isLocalOnly: true` and assigned a `localId`.
4.  **Syncing**: A `SyncTasks` event is provided to manually trigger a sync of pending changes when the connection is restored. The `TodoRepository` handles the logic of checking connectivity and performing API calls.

## Challenges & Solutions

- **Challenge**: Managing local IDs vs API IDs for new tasks.
- **Solution**: Introduced a `localId` (UUID) for tasks created offline. When syncing, the local task is replaced with the task returned by the API (which contains the real ID).
- **Challenge**: Handling offline state changes for existing tasks.
- **Solution**: Existing tasks are updated locally first. If the API call fails, the local change persists until the next sync or reload.

## Features

- Main screen with task list.
- Add new tasks via floating action button.
- Mark tasks as complete/incomplete.
- Delete tasks.
- Search functionality to filter tasks.
- Pull-to-refresh to reload tasks from the API.
- Offline support with local caching and optimistic updates.
- Mock authentication screen.
