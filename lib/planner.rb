require_relative 'week'
require 'scoped_attr_accessor/include'
require_relative 'planner_template'

class Planner
  private_attr_reader :template

  attr_reader :week

  def initialize opts
    @week = Week.new(:date => opts.fetch(:date))
    @template = PlannerTemplate.new :planner => self
  end

  def generate_into buffer
    template.generate_pdf
    template.write_to buffer
  end
end
