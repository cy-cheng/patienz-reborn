class PromptManager
  PROMPTS_DIR = Rails.root.join('config', 'prompts')

  # Load system prompt (generic patient behavior)
  def self.system_prompt
    load_prompt('system.txt')
  end

  # Load patient-specific prompt based on patient_id
  def self.patient_prompt(patient_id)
    load_prompt("#{patient_id}.txt")
  end

  # Load combined system + patient prompt
  def self.combined_prompt(patient_id)
    system = system_prompt
    patient = patient_prompt(patient_id)
    
    if patient.present?
      "#{system}\n\nPatient Background:\n#{patient}"
    else
      system
    end
  end

  # Get all available prompts
  def self.available_prompts
    return {} unless PROMPTS_DIR.exist?
    
    Dir.glob("#{PROMPTS_DIR}/*.txt").map do |file|
      name = File.basename(file, '.txt')
      next if name == 'system'
      
      content = File.read(file)
      [name, content]
    end.compact.to_h
  end

  private

  def self.load_prompt(filename)
    path = PROMPTS_DIR.join(filename)
    
    if path.exist?
      File.read(path).strip
    else
      default_system_prompt
    end
  end

  def self.default_system_prompt
    "You are a virtual patient in a medical interview. Respond realistically to the doctor's questions."
  end
end
