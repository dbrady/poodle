require "date" # needed in Ruby 1.8 for Date.today && Date.parse; remove in Ruby 2.0
require File.expand_path(File.join(File.dirname(__FILE__), "planner"))

class PlannerApplication
  def self.create opts
    klass = opts.fetch :class
    date = Date.parse(opts.fetch :date)
    buffer = opts[:buffer] || File.open(opts[:filename], "w")

    klass.new(:date => date).generate_into buffer

    buffer.close
  end
end
