# Prompt System

## Overview

The Patienz system uses a file-based prompt management system to configure patient behavior. Prompts are stored as text files in `config/prompts/` and are dynamically loaded based on the patient specialty.

## Directory Structure

```
config/prompts/
├── system.txt              # Generic system prompt
├── cardio_patient_1.txt    # Cardiology patient
├── neuro_patient_1.txt     # Neurology patient
├── gastro_patient_1.txt    # Gastroenterology patient
├── ortho_patient_1.txt     # Orthopedics patient
└── pulmo_patient_1.txt     # Pulmonology patient
```

## Prompt Types

### 1. System Prompt (`system.txt`)
Generic instructions for how the AI should behave as a patient. This is used for all patient specialties.

**Current content:**
```
You are a virtual patient in a medical interview. You are experiencing health issues 
and the doctor is interviewing you to understand your symptoms and medical history...
```

### 2. Patient-Specific Prompts
Each patient specialty has a dedicated prompt file that includes:
- Patient background (age, gender, name)
- Medical history
- Current symptoms
- Personal details (occupation, lifestyle, family history)
- Emotional state

**Example:** `cardio_patient_1.txt` describes a 58-year-old male with chest pain and family history of heart disease.

## How It Works

1. **Loading**: When a doctor starts an interview, the system loads the appropriate prompt based on `session[:patient_id]`
2. **Combining**: The generic system prompt is combined with patient-specific background
3. **First Message**: On the first message, the full combined prompt is sent to Gemini
4. **Subsequent Messages**: Conversation history is maintained, combined prompt is still used for context

## Usage

### Using the PromptManager Service

```ruby
# Load the generic system prompt
PromptManager.system_prompt

# Load patient-specific prompt
PromptManager.patient_prompt('cardio_patient_1')

# Load combined prompt (recommended)
PromptManager.combined_prompt('cardio_patient_1')

# Get all available patient prompts
PromptManager.available_prompts
```

## Adding New Patients

1. Create a new file in `config/prompts/` named `{specialty}_{patient_number}.txt`
2. Write the patient background including:
   - Demographics (age, gender, name)
   - Medical condition
   - Symptoms
   - Medical history
   - Lifestyle/family factors
   - Emotional state
3. Update the entry page to add the new patient option

### Example Template

```
You are a {age}-year-old {gender} patient named {Name} with {condition}. 
You are experiencing {symptoms}. {Background details}. 
You're seeing a {specialist} because {reason}. 
{Emotional state/concerns}. 
Be {how_to_behave} and provide natural responses. Keep responses to 1-3 sentences.
```

## Editing Existing Prompts

1. Open the prompt file in `config/prompts/`
2. Edit the content
3. Save the file
4. The changes take effect immediately on the next chat message

**No server restart needed!** Prompts are loaded dynamically for each conversation.

## Patient IDs

Patient IDs must match the filename without the `.txt` extension:

| Patient ID | File | Specialty |
|-----------|------|-----------|
| `cardio_patient_1` | `cardio_patient_1.txt` | Cardiology |
| `neuro_patient_1` | `neuro_patient_1.txt` | Neurology |
| `gastro_patient_1` | `gastro_patient_1.txt` | Gastroenterology |
| `ortho_patient_1` | `ortho_patient_1.txt` | Orthopedics |
| `pulmo_patient_1` | `pulmo_patient_1.txt` | Pulmonology |

## Best Practices

1. **Keep prompts realistic**: Use actual medical scenarios
2. **Include personality**: Show emotions, concerns, hesitation
3. **Concise format**: Prompts guide but don't force exact responses
4. **Consistency**: Maintain patient backstory across conversations
5. **Medical accuracy**: Ensure symptoms match the specialty

## System Prompt Guidelines

The system prompt guides the AI's overall behavior:
- How to respond as a patient
- Tone and style (natural, realistic, hesitant)
- Response length (1-3 sentences)
- Level of medical detail

## Troubleshooting

### Prompt not loading?
- Check file name matches patient ID exactly
- Verify file is in `config/prompts/`
- Ensure file has `.txt` extension

### Responses seem generic?
- Enhance the patient-specific prompt with more details
- Add personal background and emotional context
- Include family/medical history

### Changes not taking effect?
- Prompts are loaded per message, so refresh the browser
- Check file was saved correctly
- Verify no syntax errors in the prompt

## Future Improvements

- [ ] Web UI to manage prompts
- [ ] Prompt versioning
- [ ] A/B testing different prompts
- [ ] Analytics on prompt effectiveness
- [ ] Dynamic prompt generation from templates
