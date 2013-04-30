require "date" # needed in Ruby 1.8 for Date.today && Date.parse; remove in Ruby 2.0
require_relative "planner"

class PlannerApplication
  def self.create opts
    klass = opts.fetch :class
    date = Date.parse(opts.fetch :date)
    buffer = opts[:buffer] || File.open(opts[:filename], "w")

    klass.new(:date => date).generate_into buffer

    buffer.close
  end
end
