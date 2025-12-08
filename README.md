# Patienz - Virtual Patient Interview System

A Rails 8.1 web application that allows medical students and doctors to practice patient interviews with an AI-powered virtual patient powered by Google's Gemini 2.5 Flash model.

## Features

- **Three-page interview system**:
  1. Entry page for doctor authentication and patient selection
  2. Chat page for real-time interview with AI patient
  3. Grading page with performance evaluation

- **AI-powered patient responses** using Google Gemini 2.5 Flash
- **Real-time chat interface** with message history
- **Performance evaluation** including:
  - Relevance of questions asked
  - Communication friendliness
  - Overall interview score
- **Conversation transcripts** for review
- **Feedback on strengths and areas for improvement**

## Requirements

- Ruby 3.4+
- Rails 8.1+
- SQLite3
- Google Gemini API key

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Get Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Then edit `.env` and add your Gemini API key:

```
GEMINI_API_KEY=your_api_key_here
```

### 4. Database Setup

```bash
rails db:create
rails db:migrate
```

### 5. Run the Server

```bash
rails server
```

Visit `http://localhost:3000` in your browser.

## Architecture

### Pages

- **Entry Page** (`/entry`) - Doctor login and patient selection
- **Chat Page** (`/chat`) - Main interview interface with Gemini AI
- **Grading Page** (`/grading`) - Results with tabbed interface (Grades, Transcript, Feedback)

### Technology Stack

- **Frontend**: HTML/ERB, CSS, Vanilla JavaScript
- **Backend**: Rails 8.1
- **AI Model**: Google Gemini 2.5 Flash
- **Database**: SQLite3
- **Session Management**: Rails sessions

### JavaScript Libraries

- `@google/generative-ai` - Google Gemini SDK (loaded via CDN)
- `@hotwired/turbo-rails` - Page navigation
- `@hotwired/stimulus` - JavaScript framework

## How It Works

1. **Doctor enters name and selects patient specialty** on entry page
2. **Doctor conducts interview** by asking questions to the AI patient
3. **Gemini generates realistic patient responses** based on conversation context
4. **Doctor submits diagnosis** when finished
5. **System grades performance** and provides feedback

### Conversation Flow

```
Doctor: "What brings you in today?"
  ↓
[Message sent to page JS]
  ↓
[Gemini API generates response based on conversation history]
  ↓
Patient: "I've been having chest pain for the past few days..."
  ↓
[Response displayed and saved to session]
```

## Configuration

### Gemini Model Settings

The chat uses `gemini-2.5-flash` with:
- Max output tokens: 150
- Temperature: 0.7
- System prompt configured to respond as a medical patient

Edit these in `app/views/pages/chat.html.erb` to customize patient behavior.

## Session Data Structure

```javascript
session[:username]              // Doctor's name
session[:patient_id]            // Selected patient specialty
session[:messages]              // Array of {role, content} objects
session[:diagnosis]             // Doctor's submitted diagnosis
session[:conversation_started]  // Boolean flag
```

## Next Steps

- [ ] Implement database models for persistent storage
- [ ] Add user authentication
- [ ] Create patient profiles for different specialties
- [ ] Implement actual grading algorithm
- [ ] Add conversation export/download
- [ ] Implement multi-language support
- [ ] Add performance analytics

## Documentation

See [UI_DOCUMENTATION.md](UI_DOCUMENTATION.md) for detailed UI structure and features.

## Security Notes

- API keys are stored in environment variables, not in code
- CSRF tokens are used for all form submissions
- HTML output is escaped to prevent XSS
- Patient responses are sanitized before display

## Troubleshooting

### "Error: Unable to get response"

- Check that your Gemini API key is valid
- Ensure `.env` file exists with correct `GEMINI_API_KEY`
- Check browser console for error details
- Verify internet connection for API calls

### Messages not appearing

- Clear browser cache
- Check browser console for JavaScript errors
- Ensure JavaScript is enabled

### Session data not persisting

- Check that cookies are enabled
- Verify Rails session configuration in `config/initializers/session_store.rb`
