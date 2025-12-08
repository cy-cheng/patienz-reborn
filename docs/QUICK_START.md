# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Get Your Gemini API Key
```bash
# Visit this URL and create an API key:
# https://aistudio.google.com/apikey
```

### 2. Configure Environment
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your key
# GEMINI_API_KEY=your_actual_key_here
```

### 3. Run Setup
```bash
# Run the automated setup script
./setup.sh
```

Or manually:
```bash
bundle install
rails db:create
rails db:migrate
```

### 4. Start Server
```bash
rails server
```

### 5. Open Browser
```
http://localhost:3000
```

## 📝 Usage

1. **Enter your name** as the doctor
2. **Select a patient specialty** (Cardiology, Neurology, etc.)
3. **Ask questions** to the AI patient
4. **Get realistic responses** powered by Gemini 2.5 Flash
5. **Submit diagnosis** when finished
6. **View your grade** with feedback

## 🔧 Configuration

### Model Settings

Edit `app/views/pages/chat.html.erb` to customize:

```javascript
const chat = model.startChat({
  history: chatHistory.slice(0, -1),
  generationConfig: {
    maxOutputTokens: 150,    // ← Change response length
    temperature: 0.7,         // ← 0=deterministic, 1=creative
  },
});
```

### System Prompt

Customize patient behavior:

```javascript
const systemPrompt = `You are a virtual patient...`;
```

## 🐛 Troubleshooting

### "Error: Unable to get response"

1. Check API key is valid: `echo $GEMINI_API_KEY`
2. Ensure .env file exists: `ls -la .env`
3. Check browser console for errors (F12)
4. Verify internet connection
5. Try a simpler question first

### Messages not sending

- Ensure JavaScript is enabled
- Clear browser cache (Ctrl+Shift+Delete)
- Check browser console for errors
- Try a different browser

### "GEMINI_API_KEY is undefined"

1. Create .env file: `cp .env.example .env`
2. Add your key to .env
3. Restart Rails server
4. Clear browser cache

## 📊 Features

✓ Real-time chat with AI patient  
✓ Conversation history tracking  
✓ Performance grading  
✓ Transcript review  
✓ Feedback on interview quality  

## 🔐 Security

- API key stored in `.env` (add to `.gitignore`)
- No sensitive data in version control
- CSRF protection enabled
- HTML output escaped

## 📚 Full Documentation

- See `README.md` for complete documentation
- See `docs/GEMINI_INTEGRATION.md` for technical details
- See `UI_DOCUMENTATION.md` for UI structure

## 🆘 Need Help?

1. Check error messages in browser console (F12)
2. Review `README.md` troubleshooting section
3. Verify all environment variables are set
4. Ensure Rails server is running (port 3000)
