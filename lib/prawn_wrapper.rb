require 'prawn'
require 'forwardable'

class PrawnWrapper
  extend Forwardable
  private_attr_reader :prawn

  def_delegators :@prawn,
                 :start_new_page,
                 :render,
                 :font_size,
                 :font_size=,
                 :line_width,
                 :line_width=,
                 :stroke_line,
                 :bounding_box,
                 :stroke_bounds,
                 :text_box

  def initialize
    @prawn = Prawn::Document.new page_layout: :landscape
  end

  # Prawn's transparent function is wired backwards. A transparency of
  # 1.0 is actually completely opaque, while 0.0 is fully
  # transparent. Here is a new method, opacity, which behaves
  # correctly.
  def opacity(fill_o, stroke_o=nil, &block)
    @prawn.transparent(fill_o, stroke_o || fill_o) do
      yield
    end
  end

  # Prawn's transparent function is wired backwards. A transparency of
  # 1.0 is actually completely opaque, while 0.0 is fully
  # transparent. Here we invert the options to transparent so that
  # transparent 1.0 is actually fully transparent.
  def transparent(fill_t, stroke_t=nil, &block)
    @prawn.transparent(1.0-fill_t, 1.0-(stroke_t || fill_t)) do
      yield
    end
  end
end
