# Chat Feature - Testing & Troubleshooting

## ✅ Chat Implementation Complete

The chat page now includes:
- Real-time Gemini 2.5 Flash integration
- Conversation history tracking
- Loading indicator while waiting for response
- Error handling with recovery
- Session persistence

## 🧪 Testing the Chat

### 1. Setup

```bash
# Get API key from https://aistudio.google.com/apikey
cp .env.example .env
# Add: GEMINI_API_KEY=your_key_here

# Start server
rails server
# Visit: http://localhost:3000
```

### 2. Test Flow

**Step 1: Entry Page**
- Enter doctor name (e.g., "Dr. Smith")
- Select patient specialty (e.g., "Cardiology")
- Click "Start Interview"

**Step 2: Chat Page**
- You should see the header with your name
- Message input is ready
- Type a question: "What brings you in today?"
- Click Send or press Enter

**Expected Behavior:**
1. ✅ Your message appears on the right (blue)
2. ✅ Loading indicator appears ("Patient is thinking...")
3. ✅ Gemini generates response (1-3 seconds)
4. ✅ Patient response appears on the left (white)
5. ✅ Input field is re-enabled
6. ✅ Messages auto-scroll to show latest

**Step 3: Conversation**
- Ask follow-up questions
- Patient responds coherently
- Conversation history is maintained
- Each response takes 1-3 seconds

**Step 4: Diagnosis**
- Click "Send Diagnosis" button
- Modal dialog appears
- Type your diagnosis
- Click "Submit Diagnosis"
- Redirects to grading page

## 🐛 Troubleshooting

### Problem: "Error: Unable to get response"

**Causes & Solutions:**

1. **Invalid or Missing API Key**
   ```bash
   # Check environment variable
   echo $GEMINI_API_KEY
   
   # Should output: your_actual_key_here (not empty)
   ```
   
   **Fix:**
   - Get API key: https://aistudio.google.com/apikey
   - Edit `.env` file
   - Add: `GEMINI_API_KEY=your_actual_key`
   - Restart Rails server

2. **API Key Exposure Issue**
   - The ERB tag `<%= ENV["GEMINI_API_KEY"] %>` should render the key
   - Check browser console to see if key is `undefined`
   
   **Fix:**
   - Verify .env file exists: `ls -la .env`
   - Clear browser cache (Ctrl+Shift+Delete)
   - Restart Rails server

3. **Network/Connection Issue**
   - Check internet connection
   - Verify Google API is accessible
   - Check browser console for CORS errors
   
   **Fix:**
   - Try a simpler question
   - Refresh page
   - Try again in a few seconds

4. **API Rate Limiting**
   - Gemini free tier has rate limits
   
   **Fix:**
   - Wait a few seconds
   - Try again
   - Reduce question frequency for testing

### Problem: Messages Not Sending

**Cause:** JavaScript error

**Fix:**
1. Open browser console (F12)
2. Check for error messages
3. Look for "Error communicating with Gemini"
4. Check Network tab for failed requests
5. Verify API key in console: `typeof GEMINI_API_KEY`

### Problem: Loading Indicator Stuck

**Cause:** Gemini API is slow or timeout

**Fix:**
1. Wait 5-10 seconds (API can be slow)
2. Try a simpler, shorter question
3. Refresh page if stuck > 30 seconds
4. Check API status at https://status.cloud.google.com/

### Problem: Cannot Submit Diagnosis

**Cause:** Form validation issue

**Fix:**
1. Make sure diagnosis text is not empty
2. Click "Send Diagnosis" button
3. Modal should open
4. Type diagnosis
5. Click "Submit Diagnosis"

### Problem: "undefined" API Key in Console

**Cause:** Environment variables not loaded

**Fix:**
```bash
# Stop Rails server
# Restart it:
rails server

# OR clear and restart:
pkill -f "rails server"
sleep 2
rails server
```

## 🔍 Debugging Tips

### Check API Key in Browser

1. Open DevTools (F12)
2. Go to Console tab
3. Run: `console.log('API Key:', GEMINI_API_KEY)`
4. Check output

### Check Gemini API Calls

1. Open DevTools (F12)
2. Go to Network tab
3. Ask a question
4. Look for request to `generativelanguage.googleapis.com`
5. Check response status (should be 200)

### Check JavaScript Errors

1. Open DevTools (F12)
2. Go to Console tab
3. Look for red error messages
4. Error should show: "Error communicating with Gemini"
5. Look for specific error details

### Test with Curl (Optional)

```bash
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

## ✨ Expected Chat Behavior

### First Message
- System prompt is included
- Patient introduces themselves or responds to greeting
- Usually 1-3 sentences

### Follow-up Messages
- Patient remembers previous context
- Provides detailed, realistic responses
- Shows hesitation when appropriate
- Mentions symptoms, history, lifestyle

### Error Handling
- If API fails, error message appears
- Input is re-enabled
- User can retry
- Conversation history is preserved (except failed message)

### Loading Time
- Initial: 2-3 seconds (first API call)
- Subsequent: 1-2 seconds
- If > 5 seconds, something may be wrong

## 🎯 Success Criteria

✅ Chat is working correctly when:
- Messages send successfully
- Patient responds contextually
- Loading indicator appears and disappears
- Error messages are clear
- Diagnosis submission works
- No console errors

## 📝 Example Conversation

```
Doctor: "What brings you in today?"
[Loading: 2-3 seconds]

Patient: "I've been experiencing chest pain for the past week. 
It's worse when I exert myself, and I've also noticed some shortness of breath."

Doctor: "How severe is the chest pain on a scale of 1-10?"
[Loading: 1-2 seconds]

Patient: "I'd say about a 6 or 7 out of 10. The pain is like 
a pressure in my chest, and it radiates to my left arm sometimes."

Doctor: "Do you have any medical history of heart disease?"
[Loading: 1-2 seconds]

Patient: "My father had a heart attack in his 50s, so there is 
some family history. I'm also a smoker, which I know isn't good."
```

## 🚀 Performance Notes

- First response: ~2-3 seconds (model loading)
- Subsequent: ~1-2 seconds
- This is normal for Gemini API
- Network latency affects timing
- Shorter questions get faster responses

## 📞 Still Having Issues?

1. Check browser console (F12)
2. Verify .env file has GEMINI_API_KEY
3. Restart Rails server
4. Clear browser cache
5. Try in a fresh incognito window
6. Check Google API documentation
7. Verify API key is valid and not revoked
