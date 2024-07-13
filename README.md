
# Sentiment Analysis Flutter App

This Flutter application provides a user-friendly interface for interacting with a sentiment analysis system. Users can predict sentiments, add comments, and view existing comments from a remote server.

## Features

- Predict the sentiment of a given comment.
- Add a new comment to the database.
- View all comments in the database along with their sentiment predictions.

## Prerequisites

Before running the application, ensure you have the following installed:

- Flutter SDK
- Dart SDK
- An active internet connection for API calls

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/embarki34/your-repo-name.git
   cd your-repo-name
   ```

2. **Install dependencies:**

   Run the following command to install the required packages:

   ```bash
   flutter pub get
   ```

## Running the Application

Run the application using the following command:

```bash
flutter run
```

The app will launch in your connected device or emulator.

## API Configuration

Ensure to set the base URL for the API in the `HomePage` class:

```dart
static const String _baseUrl = 'https://honeybee-prime-supposedly.ngrok-free.app';
```

## App Structure

### 1. Main Screen

The main screen serves as the entry point of the application, providing navigation to different functionalities:

- **Home**: Overview of the app's capabilities.
- **Predict Sentiment**: Input a comment to predict its sentiment.
- **Add Comment**: Submit a new comment to the database.
- **View Comments**: Display all comments stored in the database.

### 2. Screens

- **HomeScreen**: Displays the main features of the app.
- **PredictSentimentScreen**: Allows users to input text and receive a sentiment prediction.
- **AddCommentScreen**: Enables users to add a comment and their name to the database.
- **ViewCommentsScreen**: Retrieves and displays all comments from the database.

## API Endpoints

The app interacts with the following endpoints:

### 1. Predict Sentiment

**Endpoint:** `/predict`  
**Method:** `POST`  
**Request Body:**
```json
{
    "text": "Your comment here"
}
```
**Response:**
```json
{
    "predicted_class": 1,
    "prediction_label": "positive"
}
```

### 2. Add Comment

**Endpoint:** `/add_comment`  
**Method:** `POST`  
**Request Body:**
```json
{
    "comment_text": "Your comment here",
    "commenter_name": "Your name"
}
```
**Response:**
```json
{
    "message": "Comment added successfully"
}
```

### 3. Get Comments

**Endpoint:** `/comments`  
**Method:** `GET`  
**Response:**
```json
[
    {
        "commenter_name": "Name",
        "comment_text": "Your comment",
        "prediction": "positive",
        "creation_time": "2023-01-01T00:00:00Z"
    },
    ...
]
```

## Error Handling

The application displays appropriate error messages for various failure scenarios, such as missing parameters or API errors.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Author

Omar
