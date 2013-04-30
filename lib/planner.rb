require_relative 'week'
require 'scoped_attr_accessor/include'
require_relative 'planner_template'

class Planner
  private_attr_reader :template

  def initialize opts
    date = opts.fetch :date
    @date = Week.new(:date => date).beginning_of_week
    @template = PlannerTemplate.new :date => @date
  end

  def generate_into buffer
    template.generate_pdf
    template.write_to buffer
  end
end
