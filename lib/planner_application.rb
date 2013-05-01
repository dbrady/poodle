require "date" # needed in Ruby 1.8 for Date.today && Date.parse; remove in Ruby 2.0
require File.expand_path(File.join(File.dirname(__FILE__), "planner"))
require File.expand_path(File.join(File.dirname(__FILE__), "required_keyword_args"))

class PlannerApplication
  def self.create(klass: Planner, date: Date.today.strftime('%F'), buffer: nil, filename: "planner_sheet.pdf")
    date = Date.parse date
    buffer ||= File.open filename, "w"

    klass.new(date: date).generate_into buffer

    buffer.close
  end
end
