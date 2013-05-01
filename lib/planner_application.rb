require_relative "planner"
require_relative "required_keyword_args"

class PlannerApplication
  def self.create(klass: Planner, date: Date.today.strftime('%F'), buffer: nil, filename: "planner_sheet.pdf")
    date = Date.parse date
    buffer ||= File.open filename, "w"

    klass.new(date: date).generate_into buffer

    buffer.close
  end
end
