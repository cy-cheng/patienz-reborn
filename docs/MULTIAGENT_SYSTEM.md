# Multi-Agent System Architecture for Patienz

## Executive Summary

A multi-agent system can be implemented on Patienz to create more sophisticated medical interview simulations. Multiple specialized AI agents would work together to provide realistic patient interaction, real-time feedback, performance grading, and medical knowledge validation.

**Feasibility:** ✅ Highly feasible  
**Implementation Time:** 2-3 days  
**Complexity Level:** Medium to Advanced

---

## Current Architecture vs Multi-Agent

### Current Single-Agent Model
```
Doctor Message
    ↓
Patient Agent (responds as patient)
    ↓
Response to Doctor
```

### Proposed Multi-Agent Model
```
Doctor Message
    ├→ Patient Agent (responds naturally)
    ├→ Diagnostic Agent (analyzes case, background)
    ├→ Grading Agent (scores performance)
    ├→ Feedback Agent (generates hints/coaching)
    └→ Knowledge Agent (validates medical facts)
         ↓
    All agents collaborate
         ↓
    Consolidated Response to Doctor
```

---

## Proposed Agent Types

### 1. Patient Agent (Existing) ✅
**Responsibility:** Respond as the patient in first person
**Prompt:** Specialty-specific background + patient emotions
**Output:** Natural patient responses to doctor questions
**Example:** "Yes, it started about a week ago. The pain is sharp, especially when I take a deep breath."

---

### 2. Diagnostic Agent 🆕
**Responsibility:** Analyze medical case, track symptoms, suggest diagnoses
**Prompt:** Medical knowledge base + symptom patterns + differential diagnosis
**Input:** Conversation history + patient background
**Output:** Running diagnosis hypothesis, confidence level, key missing info
**Example:** 
```json
{
  "suspected_conditions": [
    {"condition": "MI", "confidence": 0.8, "missing": ["EKG", "troponin levels"]},
    {"condition": "Angina", "confidence": 0.6, "missing": ["exercise trigger pattern"]},
    {"condition": "Pulmonary Embolism", "confidence": 0.4}
  ],
  "critical_questions_asked": 0.7,
  "critical_questions_remaining": ["Smoking history", "Risk factors"]
}
```

---

### 3. Grading Agent 🆕
**Responsibility:** Evaluate doctor's clinical competence
**Metrics:**
- Appropriate questions asked
- Relevant history collected
- Clinical reasoning quality
- Empathy and communication
- Differential diagnosis coverage

**Output:** Real-time scoring + detailed feedback
**Example:**
```json
{
  "scores": {
    "history_taking": 0.85,
    "clinical_reasoning": 0.72,
    "empathy": 0.90,
    "efficiency": 0.65,
    "overall": 0.78
  },
  "feedback": "Good rapport, but missing medication history",
  "warning": "You haven't asked about risk factors"
}
```

---

### 4. Feedback Agent 🆕
**Responsibility:** Generate real-time coaching and hints
**Triggers:**
- Doctor asks irrelevant question → Provide gentle redirect
- Doctor misses critical symptom → Suggest areas to explore
- Doctor makes clinical error → Warn appropriately
- Doctor does well → Provide positive reinforcement

**Output:** Coaching messages, hints, encouragement
**Example:**
```
"Good question! You might also want to ask about..."
"Consider what this symptom pattern could indicate..."
"Have you explored the patient's risk factors?"
```

---

### 5. Knowledge Agent 🆕
**Responsibility:** Validate medical facts and provide accurate information
**Functions:**
- Check if doctor's statements are medically accurate
- Provide quick reference information
- Flag misconceptions
- Suggest evidence-based approaches

**Output:** Fact validation, resources, corrections
**Example:**
```json
{
  "doctor_statement": "Your heart will recover fully from a mild heart attack",
  "validation": "PARTIALLY_CORRECT",
  "correction": "Some cardiac damage may persist. Recovery depends on severity."
}
```

---

## Implementation Architecture

### Directory Structure
```
app/services/
├── agent_manager.rb          # Orchestrates all agents
├── agents/
│   ├── base_agent.rb         # Base class for all agents
│   ├── patient_agent.rb      # Patient responses
│   ├── diagnostic_agent.rb   # Medical analysis
│   ├── grading_agent.rb      # Performance evaluation
│   ├── feedback_agent.rb     # Coaching/hints
│   └── knowledge_agent.rb    # Fact validation
└── agent_context.rb          # Shared context between agents

config/prompts/agents/
├── patient_system.txt
├── diagnostic_system.txt
├── grading_system.txt
├── feedback_system.txt
└── knowledge_system.txt
```

### Base Agent Class
```ruby
class BaseAgent
  attr_reader :name, :role, :system_prompt, :memory
  
  def initialize(name, role, patient_id)
    @name = name
    @role = role
    @system_prompt = load_prompt(role)
    @memory = []
  end
  
  def process(message, context)
    # Each agent implements this
    raise NotImplementedError
  end
  
  def add_to_memory(message, response)
    @memory << { message, response, timestamp: Time.now }
  end
end
```

### Agent Manager (Orchestrator)
```ruby
class AgentManager
  def initialize(patient_id, session)
    @patient_id = patient_id
    @session = session
    @agents = initialize_agents
    @context = AgentContext.new
  end
  
  def process_message(doctor_message)
    # Sequential or parallel execution
    responses = {}
    
    responses[:patient] = @agents[:patient].process(doctor_message, @context)
    responses[:diagnostic] = @agents[:diagnostic].analyze(@context)
    responses[:grading] = @agents[:grading].evaluate(@context)
    responses[:feedback] = @agents[:feedback].generate_hints(@context)
    
    # Merge responses
    consolidate_responses(responses)
  end
  
  private
  
  def initialize_agents
    {
      patient: PatientAgent.new(@patient_id),
      diagnostic: DiagnosticAgent.new(@patient_id),
      grading: GradingAgent.new(@patient_id),
      feedback: FeedbackAgent.new(@patient_id),
      knowledge: KnowledgeAgent.new(@patient_id)
    }
  end
  
  def consolidate_responses(responses)
    # Merge all agent outputs intelligently
    {
      patient_response: responses[:patient],
      diagnostic_analysis: responses[:diagnostic],
      performance_metrics: responses[:grading],
      coaching_hints: responses[:feedback]
    }
  end
end
```

---

## Agent Communication Patterns

### Pattern 1: Sequential Execution (Simple)
```
Doctor Message
    ↓
Patient Agent responds
    ↓
Diagnostic Agent analyzes
    ↓
All results aggregated
    ↓
Response to doctor
```
**Pros:** Simple, deterministic  
**Cons:** Slower (all agents run sequentially)  
**Execution Time:** ~3-5 seconds

---

### Pattern 2: Parallel Execution (Fast)
```
Doctor Message
    ├→ Patient Agent (parallel)
    ├→ Diagnostic Agent (parallel)
    ├→ Grading Agent (parallel)
    └→ Feedback Agent (parallel)
         ↓
    All complete → Aggregate results
         ↓
    Response to doctor
```
**Pros:** Faster  
**Cons:** More complex, higher API costs  
**Execution Time:** ~1-2 seconds

---

### Pattern 3: Agent Consensus (Sophisticated)
```
Doctor Message
    ↓
Each agent generates preliminary response
    ↓
Meta-Agent evaluates consistency
    ↓
Resolve conflicts if any
    ↓
Final consolidated response
```
**Pros:** More coherent, fewer contradictions  
**Cons:** Most complex  
**Execution Time:** ~2-3 seconds

---

## Data Structures

### Agent Context (Shared State)
```ruby
class AgentContext
  attr_accessor :conversation_history, :patient_data, :doctor_profile, :case_analysis
  
  def initialize
    @conversation_history = []
    @patient_data = {}
    @doctor_profile = {}
    @case_analysis = {}
  end
  
  def add_exchange(doctor_msg, patient_response, analysis)
    @conversation_history << {
      doctor: doctor_msg,
      patient: patient_response,
      diagnostic_notes: analysis,
      timestamp: Time.now
    }
  end
  
  def get_summary
    # Generate summary for agents
  end
end
```

### Agent Response Structure
```ruby
{
  agent_name: "PatientAgent",
  timestamp: Time.now,
  response: "Yes, the pain started...",
  confidence: 0.9,
  metadata: {
    emotion: :anxious,
    consistency: true
  }
}
```

---

## Use Cases

### 1. Real-Time Coaching 🎯
**Scenario:** Doctor asks medically irrelevant question
**System Response:**
```
Patient: "Umm, I'm not sure how that relates to my chest pain..."
Feedback Agent: "Consider focusing on the primary complaint first"
```

---

### 2. Automated Grading 📊
**Scenario:** End of interview
**System Output:**
```
Patient Risk Assessment: 65% accuracy
Diagnostic Reasoning: 72% accuracy
Clinical Communication: 88% accuracy
Overall Score: 75/100
```

---

### 3. Case Difficulty Adaptation 🔄
**Scenario:** Doctor performing very well
**System Response:**
```
Diagnostic Agent increases case complexity
- Adds atypical presentation
- Includes confounding symptoms
- Requires deeper differential thinking
```

---

### 4. Medical Fact-Checking ✓
**Scenario:** Doctor states a medical fact
**System Response:**
```
Doctor: "Aspirin reduces cardiac mortality by 30%"
Knowledge Agent: "✓ ACCURATE - Based on current guidelines"

Doctor: "Mild chest pain is always cardiac in origin"
Knowledge Agent: "✗ INACCURATE - Consider alternative diagnoses"
```

---

### 5. Performance Analytics 📈
**Scenario:** After multiple interviews
**System Output:**
```
Doctor's Performance Trends:
- History Taking: 72% → 81% ↗
- Differential Diagnosis: 65% → 73% ↗
- Communication: 85% → 88% ↗
- Areas to Improve: Physical exam findings
```

---

## Implementation Roadmap

### Phase 1: Foundation (Days 1-1.5)
- [ ] Create `BaseAgent` class
- [ ] Implement `AgentManager` orchestrator
- [ ] Create `AgentContext` for shared state
- [ ] Implement `PatientAgent` (refactor existing)
- [ ] Create prompt files for all agents

**Time:** 4-6 hours  
**Result:** Working framework for agents

---

### Phase 2: Core Agents (Days 1.5-2)
- [ ] Implement `DiagnosticAgent`
- [ ] Implement `GradingAgent`
- [ ] Implement `FeedbackAgent`
- [ ] Create agent communication protocol
- [ ] Implement sequential execution pattern

**Time:** 6-8 hours  
**Result:** Multiple agents working together

---

### Phase 3: Advanced Features (Days 2-3)
- [ ] Implement parallel execution
- [ ] Add agent consensus mechanism
- [ ] Implement `KnowledgeAgent` for fact-checking
- [ ] Add performance analytics
- [ ] Create admin dashboard for agent configuration

**Time:** 8-10 hours  
**Result:** Production-ready multi-agent system

---

### Phase 4: Optimization (Ongoing)
- [ ] API call batching to reduce costs
- [ ] Agent response caching
- [ ] Performance monitoring
- [ ] A/B testing different agent configurations
- [ ] Agent learning from user feedback

**Time:** Variable  
**Result:** Optimized, efficient system

---

## Cost Analysis

### API Call Costs (per interaction)

#### Single Agent (Current)
- 1 API call (Patient Agent)
- ~$0.0001 per call
- **Cost per message:** $0.0001

#### Multi-Agent (Proposed)
- 5 API calls (all agents run)
- ~5 × $0.0001
- **Cost per message:** $0.0005

**Monthly Impact (1000 messages/month):**
- Single Agent: $0.10
- Multi-Agent: $0.50

**Optimization:** Can reduce to 2-3 calls with batching

---

## Testing Strategy

### Unit Tests
```ruby
# Test individual agents
describe PatientAgent do
  it "responds naturally to questions"
  it "maintains character consistency"
  it "provides medically accurate information"
end

describe DiagnosticAgent do
  it "identifies correct differential diagnoses"
  it "tracks missing clinical information"
  it "provides reasonable confidence scores"
end
```

### Integration Tests
```ruby
# Test agent communication
describe AgentManager do
  it "coordinates multiple agents"
  it "consolidates responses correctly"
  it "handles agent conflicts"
end
```

### Scenario Tests
```ruby
# Test real medical scenarios
describe "MI Case" do
  it "Patient agent describes cardiac symptoms"
  it "Diagnostic agent identifies MI risk"
  it "Grading agent scores performance"
end
```

---

## Challenges & Solutions

### Challenge 1: Response Latency
**Problem:** 5 agents × 1-2 seconds each = 5-10 seconds total
**Solution:** 
- Implement parallel execution (reduces to 1-2 seconds)
- Cache common responses
- Pre-load models

---

### Challenge 2: Agent Consistency
**Problem:** Agents might contradict each other
**Solution:**
- Shared `AgentContext` for consistency
- Consensus mechanism for conflicts
- Single source of truth for patient data

---

### Challenge 3: API Costs
**Problem:** 5× more API calls = 5× cost
**Solution:**
- Batch API calls
- Use cheaper models for some agents
- Cache responses
- Run some agents locally

---

### Challenge 4: State Management
**Problem:** Tracking state for 5 agents
**Solution:**
- Centralized `AgentContext`
- Session-based storage
- Agent-specific memory caches

---

### Challenge 5: Agent Hallucination
**Problem:** Agents might generate false medical information
**Solution:**
- Knowledge Agent validates all outputs
- Use constrained prompts
- Regular human review
- Feedback loops for corrections

---

## Scalability Considerations

### For 1000 Users Simultaneously

#### Resources Needed
- Load balancer: Distribute requests
- API quota: 5000 Gemini API calls/minute (scalable)
- Database: Store conversation histories
- Cache: Redis for agent responses

#### Architecture
```
Load Balancer
    ↓
Web Servers (multiple)
    ↓
Agent Manager (session-based)
    ↓
Gemini API (batched calls)
    ↓
Cache (Redis)
```

#### Expected Costs (Monthly)
- Gemini API: $100-500
- Infrastructure: $200-1000
- Database: $50-200

---

## Metrics & KPIs

### Agent Performance
- Patient Agent: Response quality, consistency, realism
- Diagnostic Agent: Accuracy of diagnosis, relevance of analysis
- Grading Agent: Correlation with human evaluators
- Feedback Agent: Usefulness of hints
- Knowledge Agent: Fact validation accuracy

### System Performance
- Response latency: Target < 2 seconds
- API success rate: Target > 99%
- Cost per interaction: Track and optimize
- User satisfaction: Feedback scoring

### Educational Outcomes
- Doctor performance improvement: Pre/Post scores
- Knowledge retention: Follow-up tests
- Skills assessment: Competency tracking

---

## Future Enhancements

### Short Term (1-3 months)
- [ ] Add more specialty patients
- [ ] Implement adaptive case difficulty
- [ ] Add supervisor mode (observe real doctor)
- [ ] Create performance reports

### Medium Term (3-6 months)
- [ ] Machine learning for agent improvement
- [ ] Natural language understanding improvements
- [ ] Multi-language support
- [ ] Mobile app integration

### Long Term (6+ months)
- [ ] VR/AR integration for immersive learning
- [ ] Collaborative multi-doctor cases
- [ ] Hospital integration (real patient simulator)
- [ ] Research data analysis

---

## Conclusion

A multi-agent system for Patienz is **highly feasible and would significantly enhance the educational value** of the platform. The current architecture supports it well, and implementation would take 2-3 days for a working prototype.

**Key Benefits:**
✅ More realistic patient interactions  
✅ Real-time performance feedback  
✅ Personalized coaching  
✅ Automated assessment  
✅ Better learning outcomes

**Recommended Next Step:** 
Implement Phase 1 (Foundation) to establish the agent framework, then iteratively add agents.

---

## References

- Gemini API Documentation: https://ai.google.dev/gemini-api/docs
- Multi-Agent Systems: https://en.wikipedia.org/wiki/Multi-agent_system
- Medical Education Standards: ACGME competencies
- Reinforcement Learning for Agents: https://openai.com/research

---

**Document Created:** 2025-11-18  
**Status:** Planning & Design Phase  
**Ready for Implementation:** Yes ✅
