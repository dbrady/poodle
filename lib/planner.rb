require_relative 'week'
require 'scoped_attr_accessor/include'
require_relative 'planner_template'
require 'date'

class Planner
  private_attr_reader :template

  attr_reader :week

  def initialize(date: Date.today)
    @week = Week.new date: date
    @template = PlannerTemplate.new planner: self
  end

  def generate_into buffer
    template.generate_pdf
    template.write_to buffer
  end
end
