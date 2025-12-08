# Patienz Documentation Index

Complete documentation for the Patienz virtual patient interview system.

**Last Updated:** 2025-11-18 04:43:41 UTC

---

## 📋 Quick Navigation

### Getting Started
- **[QUICK_START.md](QUICK_START.md)** - Setup and first run
- **[UI_DOCUMENTATION.md](UI_DOCUMENTATION.md)** - User interface guide

### Core Features
- **[PROMPT_SYSTEM.md](PROMPT_SYSTEM.md)** - File-based prompt management
- **[GEMINI_INTEGRATION.md](GEMINI_INTEGRATION.md)** - Gemini API setup and usage
- **[CHAT_IMPLEMENTATION.md](CHAT_IMPLEMENTATION.md)** - Chat feature architecture

### Technical Details
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Technical architecture overview
- **[API_FIX.md](API_FIX.md)** - API integration issues and fixes
- **[CHAT_TESTING.md](CHAT_TESTING.md)** - Testing and debugging

### Session Records
- **[SESSION_SUMMARY.md](SESSION_SUMMARY.md)** - Latest session (2025-11-18)

### Future Plans
- **[MULTIAGENT_SYSTEM.md](MULTIAGENT_SYSTEM.md)** - Multi-agent architecture design

---

## 📚 Documentation by Topic

### Setup & Configuration
1. **Environment Variables**
   - File: `QUICK_START.md`
   - Section: "Environment Setup"
   - How to: Set up `.env` file with API key

2. **Dependencies**
   - File: `IMPLEMENTATION_SUMMARY.md`
   - Section: "Gemfile & Dependencies"
   - What: Rails 8, Gemini API, dotenv-rails

3. **Database**
   - File: `QUICK_START.md`
   - Section: "Database Setup"
   - How to: Run migrations

### Features
1. **Chat System**
   - File: `CHAT_IMPLEMENTATION.md`
   - Overview: Message exchange between doctor and patient
   - Architecture: Client-server with session storage

2. **Prompt System**
   - File: `PROMPT_SYSTEM.md`
   - Overview: File-based patient specialty prompts
   - Customization: Add/edit prompts without code changes

3. **Grading System**
   - File: `IMPLEMENTATION_SUMMARY.md`
   - Section: "Grading Module"
   - Status: Planned, basic structure in place

### Development
1. **API Integration**
   - File: `GEMINI_INTEGRATION.md`
   - Topic: How Gemini API is used
   - Security: Server-side integration, no client exposure

2. **Debugging**
   - File: `CHAT_TESTING.md`
   - Topic: Testing chat functionality
   - Tools: Browser DevTools, Rails logs

3. **Code Structure**
   - File: `IMPLEMENTATION_SUMMARY.md`
   - Topic: MVC architecture breakdown
   - Routes: Page controller mapping

---

## 🗂️ Directory Structure Reference

### Code
```
app/
├── controllers/
│   └── pages_controller.rb      # Main controller (documented in SESSION_SUMMARY)
├── services/
│   └── prompt_manager.rb        # Prompt loading service (documented in PROMPT_SYSTEM)
└── views/pages/
    ├── entry.html.erb           # Entry page
    ├── chat.html.erb            # Chat interface
    └── grading.html.erb         # Grading display

config/
├── routes.rb                    # Route definitions (documented in SESSION_SUMMARY)
├── prompts/                     # Patient prompts (documented in PROMPT_SYSTEM)
│   ├── system.txt
│   ├── cardio_patient_1.txt
│   ├── neuro_patient_1.txt
│   ├── gastro_patient_1.txt
│   ├── ortho_patient_1.txt
│   └── pulmo_patient_1.txt
└── application.rb              # Rails config (documented in SESSION_SUMMARY)

docs/                           # All documentation
├── QUICK_START.md
├── UI_DOCUMENTATION.md
├── PROMPT_SYSTEM.md
├── GEMINI_INTEGRATION.md
├── CHAT_IMPLEMENTATION.md
├── IMPLEMENTATION_SUMMARY.md
├── API_FIX.md
├── CHAT_TESTING.md
├── SESSION_SUMMARY.md
├── MULTIAGENT_SYSTEM.md
└── INDEX.md                     # This file
```

---

## 🔍 Finding What You Need

### I want to...

#### Start the application
→ **QUICK_START.md**
- Step 1: Environment setup
- Step 2: Install dependencies
- Step 3: Start server

#### Understand the user interface
→ **UI_DOCUMENTATION.md**
- Entry page layout
- Chat interface
- Grading page

#### Add a new patient specialty
→ **PROMPT_SYSTEM.md**
- Section: "Adding New Patients"
- Create prompt file
- Update UI

#### Fix a bug in chat
→ **CHAT_TESTING.md**
- Debugging checklist
- Common issues
- Log inspection

#### Understand API integration
→ **GEMINI_INTEGRATION.md** + **API_FIX.md**
- How Gemini API is called
- Security practices
- Common errors

#### See what was fixed recently
→ **SESSION_SUMMARY.md**
- All fixes from 2025-11-18
- Before/after comparisons
- Testing recommendations

#### Plan multi-agent system
→ **MULTIAGENT_SYSTEM.md**
- Architecture design
- Implementation roadmap
- Use cases

#### Get technical overview
→ **IMPLEMENTATION_SUMMARY.md**
- Full architecture
- Technologies used
- File breakdown

---

## 📊 Document Statistics

| Document | Type | Lines | Topics | Created |
|----------|------|-------|--------|---------|
| SESSION_SUMMARY.md | Technical Summary | 362 | 8 fixes, overview | 2025-11-18 |
| MULTIAGENT_SYSTEM.md | Architecture Design | 655 | Multi-agent system | 2025-11-18 |
| PROMPT_SYSTEM.md | Feature Guide | 148 | Prompts, usage | Earlier |
| IMPLEMENTATION_SUMMARY.md | Technical Overview | ~200 | Architecture | Earlier |
| GEMINI_INTEGRATION.md | Technical Guide | ~100 | API usage | Earlier |
| CHAT_IMPLEMENTATION.md | Feature Guide | ~150 | Chat flow | Earlier |
| QUICK_START.md | Getting Started | ~100 | Setup | Earlier |
| UI_DOCUMENTATION.md | User Guide | ~150 | UI/UX | Earlier |
| CHAT_TESTING.md | Testing Guide | ~200 | Testing | Earlier |
| API_FIX.md | Bug Fix | ~100 | API issues | Earlier |

**Total Documentation:** ~2000 lines of comprehensive guides

---

## 🔄 Documentation Workflow

### When Starting Development
1. Read **QUICK_START.md** (setup)
2. Read **IMPLEMENTATION_SUMMARY.md** (architecture)
3. Read **SESSION_SUMMARY.md** (recent changes)

### When Adding Features
1. Check relevant feature doc (e.g., **PROMPT_SYSTEM.md** for prompts)
2. Review **CHAT_IMPLEMENTATION.md** for system patterns
3. Check **SESSION_SUMMARY.md** for recent conventions

### When Debugging
1. Check **CHAT_TESTING.md** for troubleshooting
2. Review **API_FIX.md** if API-related
3. Consult **SESSION_SUMMARY.md** for common issues

### When Planning Major Changes
1. Review **IMPLEMENTATION_SUMMARY.md** (current architecture)
2. Check **MULTIAGENT_SYSTEM.md** (future architecture)
3. Update documentation as you go

---

## 🏗️ Architecture Overview (Brief)

```
┌─────────────────────────────────────────────────────┐
│          Browser / Client (JavaScript)               │
├─────────────────────────────────────────────────────┤
│  Entry Page  │  Chat Interface  │  Grading Display  │
└────────────────────────┬────────────────────────────┘
                         │ HTTP Requests
                         ↓
┌─────────────────────────────────────────────────────┐
│         Rails Server (Ruby on Rails 8)               │
├─────────────────────────────────────────────────────┤
│  PagesController                                     │
│  ├─ entry (page routing)                            │
│  ├─ generate_response (Gemini API call)             │
│  ├─ submit_diagnosis (grading logic)                │
│  └─ (other page actions)                            │
├─────────────────────────────────────────────────────┤
│  PromptManager Service                              │
│  └─ Loads patient prompts dynamically               │
├─────────────────────────────────────────────────────┤
│  Session Storage (Doctor + Conversation Data)       │
└────────────────────────┬────────────────────────────┘
                         │ HTTPS
                         ↓
┌─────────────────────────────────────────────────────┐
│            Gemini API (Google)                       │
├─────────────────────────────────────────────────────┤
│  ✅ Server-side only (API key never exposed)        │
│  ✅ All LLM calls authenticated                     │
│  ✅ Responses processed server-side                 │
└─────────────────────────────────────────────────────┘
```

**Key Security:** API key stays on server. Client never sees it.

---

## 🚀 Quick Commands

### Start Server
```bash
cd /home/brine/OneDrive/Work/patienz
rails server
# Open http://localhost:3000
```

### View Logs
```bash
tail -f log/development.log
```

### Test Prompts
```bash
rails runner "puts PromptManager.combined_prompt('cardio_patient_1')"
```

### Check Routes
```bash
rails routes | grep -E "entry|chat|grading"
```

### Run Tests
```bash
rails test
```

### Clear Cache
```bash
rm -rf tmp/cache
```

---

## 📖 Reading Guide by Role

### For Doctors/Clinicians Using the System
→ Start with: **QUICK_START.md** → **UI_DOCUMENTATION.md**

### For Developers Adding Features
→ Start with: **IMPLEMENTATION_SUMMARY.md** → **SESSION_SUMMARY.md** → Feature-specific docs

### For DevOps/Deployment
→ Start with: **QUICK_START.md** → **IMPLEMENTATION_SUMMARY.md** (Dependencies section)

### For Project Managers
→ Start with: **SESSION_SUMMARY.md** → **MULTIAGENT_SYSTEM.md** (roadmap)

### For QA/Testers
→ Start with: **CHAT_TESTING.md** → **UI_DOCUMENTATION.md**

---

## 🔗 Cross-References

### Frequently Linked Topics

**Prompts:**
- How to use: PROMPT_SYSTEM.md
- How they're loaded: SESSION_SUMMARY.md (Prompt System section)
- Where they're stored: IMPLEMENTATION_SUMMARY.md (Directory structure)

**API Integration:**
- How to set up: QUICK_START.md (Environment Setup)
- How it works: GEMINI_INTEGRATION.md
- Recent fixes: API_FIX.md, SESSION_SUMMARY.md (API Key Security section)
- Security: SESSION_SUMMARY.md (API Key Security section)

**Chat Feature:**
- How to use: UI_DOCUMENTATION.md
- How it works: CHAT_IMPLEMENTATION.md
- Issues: CHAT_TESTING.md (Troubleshooting)
- Recent fixes: SESSION_SUMMARY.md

---

## 📝 Documentation Standards

All documentation in this project follows:
- **Format:** Markdown (.md)
- **Structure:** H1 title, table of contents, sections, examples
- **Code Examples:** Syntax highlighting with language tags
- **Links:** Relative paths to other docs
- **Updates:** Last updated date at top/bottom
- **Completeness:** Aim for 80%+ coverage before release

---

## 🎯 Next Steps

### To Continue Development
1. ✅ Read SESSION_SUMMARY.md (understand recent changes)
2. ✅ Read MULTIAGENT_SYSTEM.md (plan next features)
3. ✅ Choose feature to implement
4. ✅ Review relevant documentation
5. ✅ Update docs as you code

### To Deploy to Production
1. Read QUICK_START.md (environment setup)
2. Review IMPLEMENTATION_SUMMARY.md (dependencies)
3. Check security in SESSION_SUMMARY.md (API Key Security section)
4. Set up production environment
5. Deploy!

### To Contribute
1. Read IMPLEMENTATION_SUMMARY.md (architecture)
2. Read SESSION_SUMMARY.md (conventions)
3. Follow code style from existing files
4. Update relevant documentation
5. Submit changes

---

## 📞 Support

### Common Issues
- **API Key not loading?** → See SESSION_SUMMARY.md (Environment Variables section)
- **Chat not responding?** → See CHAT_TESTING.md (Troubleshooting section)
- **Route not found?** → See SESSION_SUMMARY.md (Route Helpers section)
- **Prompt not loading?** → See PROMPT_SYSTEM.md (Troubleshooting section)

### More Help
- Check log files: `tail -f log/development.log`
- Review recent fixes: SESSION_SUMMARY.md
- Check related docs: Use cross-references in this index

---

## 📅 Maintenance Schedule

| Task | Frequency | Owner | Location |
|------|-----------|-------|----------|
| Update docs | With each feature | Developer | docs/ |
| Review architecture | Monthly | Tech Lead | IMPLEMENTATION_SUMMARY.md |
| Update session notes | Each session | Developer | SESSION_SUMMARY.md |
| Check links | Quarterly | Anyone | docs/ |
| Archive old docs | Yearly | Admin | docs/archive/ |

---

## ✅ Documentation Checklist

Before considering a feature complete:
- [ ] Feature is implemented
- [ ] Code is tested
- [ ] Related documentation is updated
- [ ] New docs created if applicable
- [ ] Examples added if helpful
- [ ] Links updated in INDEX.md
- [ ] No broken markdown links
- [ ] SESSION_SUMMARY.md updated if relevant

---

**Documentation Version:** 1.0  
**Last Updated:** 2025-11-18 04:43:41 UTC  
**Maintainer:** Development Team  
**Status:** Active & Maintained ✅

For questions or updates, please refer to the relevant documentation file or create an issue with documentation tag.
