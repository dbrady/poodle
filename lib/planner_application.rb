require "date" # needed in Ruby 1.8 for Date.today && Date.parse; remove in Ruby 2.0
require_relative "planner"

class PlannerApplication
  def self.create opts
    klass = opts.fetch :class
    date = Date.parse(opts.fetch :date)
    filename = opts.fetch :filename

    klass.create :date => date, :filename => filename
  end
end
