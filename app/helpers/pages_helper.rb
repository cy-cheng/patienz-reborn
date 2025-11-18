module PagesHelper
  def grade_color(score)
    case score
    when 80..100
      'excellent'
    when 60..79
      'good'
    when 40..59
      'fair'
    else
      'poor'
    end
  end
end
