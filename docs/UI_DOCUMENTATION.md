# Patienz UI Documentation

## Project Structure

This is a Rails 8.1 application with a three-page interview system for doctors to practice patient interactions.

### Pages

#### 1. **Entry Page** (`/entry`)
- **Purpose**: User login and patient selection
- **Features**:
  - Username input field (for doctor name)
  - Patient specialty dropdown selector
    - Cardiology
    - Neurology
    - Gastroenterology
    - Orthopedics
    - Pulmonology
  - Beautiful gradient background
  - Start Interview button

#### 2. **Chat Page** (`/chat`)
- **Purpose**: Main interview interface
- **Features**:
  - Chat header showing doctor name and patient ID
  - Message display area with message history
    - User messages (right-aligned, blue background)
    - Patient messages (left-aligned, white background)
  - Input field for typing questions
  - Send button for message submission
  - Send Diagnosis button (opens modal)
  - Back button (with confirmation)
  - Diagnosis modal dialog
  - Real-time message updates via JavaScript

#### 3. **Grading Page** (`/grading`)
- **Purpose**: Results and performance evaluation
- **Features**:
  - Three tabbed sections:
    - **Grades**: Visual score cards for:
      - Relevant Questions (%)
      - Friendliness & Communication (%)
      - Overall Score (%)
    - **Transcript**: Full conversation history
    - **Feedback**: Doctor's diagnosis and evaluation feedback
  - Score color coding:
    - Green (80-100): Excellent
    - Blue (60-79): Good
    - Yellow (40-59): Fair
    - Red (0-39): Poor
  - Back to Chat button
  - New Interview button

### File Structure

```
app/
├── controllers/
│   └── pages_controller.rb          # Main controller for all pages
├── helpers/
│   └── pages_helper.rb              # Helper for grade color coding
├── views/
│   ├── layouts/
│   │   └── application.html.erb    # Main layout
│   └── pages/
│       ├── entry.html.erb          # Entry page
│       ├── chat.html.erb           # Chat page with inline styles & scripts
│       └── grading.html.erb        # Grading page with tabbed interface
├── assets/
│   └── stylesheets/
│       └── application.css         # Global styles
config/
└── routes.rb                        # Page routing
```

### Session Management

User data is stored in Rails sessions:
- `session[:username]` - Doctor's name
- `session[:patient_id]` - Selected patient
- `session[:messages]` - Array of messages (role, content)
- `session[:diagnosis]` - Doctor's diagnosis
- `session[:conversation_started]` - Flag for conversation state

### Routing

- `GET /` → Entry page (root)
- `GET /entry` → Entry page
- `POST /entry` → Create session
- `GET /chat` → Chat page
- `POST /chat/send` → Send message (returns JSON)
- `POST /chat/diagnose` → Submit diagnosis
- `GET /grading` → Grading page
- `POST /grading/back_to_chat` → Return to chat

### Styling

All pages use:
- Modern, clean design with card-based layouts
- Responsive grid layouts (mobile-friendly)
- Color-coded messaging (blue for doctor, white for patient)
- Gradient backgrounds
- Smooth transitions and animations
- Accessible form controls with focus states

### JavaScript Features

- Real-time message sending without page reload
- Diagnosis modal dialog management
- Tab switching on grading page
- Message auto-scroll
- HTML escaping for security
- CSRF token handling for form submissions

### Next Steps for Development

1. **LLM Integration**: Replace placeholder patient responses with LLM API calls
2. **Database Models**: Create persistent storage for:
   - Users
   - Patients
   - Conversations
   - Assessments
3. **Grading Logic**: Implement actual evaluation algorithm
4. **Patient Profiles**: Create patient definitions for different specialties
5. **Authentication**: Replace session-based entry with proper login
