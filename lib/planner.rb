require "prawn"
require_relative 'prawn_patches'
require_relative 'week'
require 'scoped_attr_accessor/include'

class Planner
  def initialize opts
    date = opts.fetch :date
    @date = Week.new(:date => date).beginning_of_week
  end

  def generate_into buffer
    generate_pdf
    write_to buffer
  end
  private_attr_reader :pdf, :date

  private

  # Prawn-specific page layout units
  PDF_GUTTER_OVERLAP_X=30
  PDF_GUTTER_OVERLAP_Y=30
  PAGE_WIDTH=720.0
  PAGE_HEIGHT=540.0
  PAGE_LEFT=-30
  PAGE_TOP=-30
  TIME_SLOT_HEIGHT=9
  HEADER_HEIGHT=18
  CHECK_COLUMN_WIDTH=9
  TITLE_LABEL_WIDTH=150
  TITLE_LABEL_HEIGHT=18
  TITLE_X=PAGE_WIDTH-TITLE_LABEL_WIDTH
  TITLE_Y=PAGE_HEIGHT+TITLE_LABEL_HEIGHT+4

  # Prawn-specific appearance characteristics
  THICK_LINE_WIDTH=0.2
  THIN_LINE_WIDTH=0.1
  LIGHT_LINE_OPACITY=0.75
  HOURLY_LABEL_FONT_SIZE=8

  # Some useful derived constants
  BODY_TOP=PAGE_TOP+HEADER_HEIGHT
  BODY_HEIGHT=PAGE_HEIGHT-HEADER_HEIGHT
  ROWS=BODY_HEIGHT/TIME_SLOT_HEIGHT

  # Total number of columns=8, but one is for TODO's
  DAYS_PER_WEEK=7
  TODO_COLUMNS=1
  # This is it--the number of columns on the front side of the planner
  COLUMNS=TODO_COLUMNS+DAYS_PER_WEEK
  COLUMN_WIDTH=PAGE_WIDTH/COLUMNS

  # Hour labels are marked on the planner
  START_HOUR=8
  END_HOUR=20

  # Right now time slots are 30 minutes
  HOUR_HEIGHT=TIME_SLOT_HEIGHT*2

  # The back page has 4x2 large sections, each filled with graph paper
  GRAPH_MAJOR_COLUMNS=4
  GRAPH_MAJOR_ROWS=2
  GRAPH_CELL_HEIGHT=9
  GRAPH_CELL_WIDTH=9

  def write_to file
    file.write pdf.render
  end

  def generate_pdf
    @pdf = Prawn::Document.new page_layout: :landscape
    generate_front_page
    pdf.start_new_page
    generate_back_page
    @pdf
  end

  def generate_front_page
    draw_planner_skeleton
    draw_labels
  end

  def generate_back_page
    draw_graph_paper
    draw_octant_outlines
  end

  def with_prawn_setting setting, value, &block
    old_value = pdf.send setting
    pdf.send "#{setting}=", value
    yield
    pdf.send "#{setting}=", old_value
  end

  def with_font_size font_size, &block
    with_prawn_setting(:font_size, font_size) do
      yield
    end
  end

  def with_line_width line_width, &block
    with_prawn_setting(:line_width, line_width) do
      yield
    end
  end

  def with_thick_pen &block
    with_line_width(THICK_LINE_WIDTH) do
      yield
    end
  end

  def with_thin_pen &block
    with_line_width(THIN_LINE_WIDTH) do
      yield
    end
  end

  def with_light_pen &block
    pdf.opacity LIGHT_LINE_OPACITY do
      yield
    end
  end

  def draw_time_slots
    with_thin_pen do
      with_light_pen do
        (0..BODY_HEIGHT).step(TIME_SLOT_HEIGHT) do |y|
          pdf.stroke_line [0,y], [PAGE_WIDTH,y]
        end
      end
    end
  end

  def draw_columns
    with_thick_pen do
      (0..PAGE_WIDTH).step(COLUMN_WIDTH) do |x|
        pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
      end
    end
  end

  def draw_checkoff_columns
    with_thin_pen do
      (0...PAGE_WIDTH).step(COLUMN_WIDTH).map {|i| i + CHECK_COLUMN_WIDTH }.each do |x|
        pdf.stroke_line [x,0], [x,BODY_HEIGHT]
      end
    end
  end

  def draw_lines_around_header_and_bottom
    with_thick_pen do
      [0,BODY_HEIGHT,PAGE_HEIGHT].each do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
    end
  end

  def draw_planner_skeleton
    draw_time_slots
    draw_columns
    draw_checkoff_columns
    draw_lines_around_header_and_bottom
  end

  def draw_page_title
    label = Week.new(:date => date).date_label

    with_thick_pen do
      pdf.bounding_box [TITLE_X, TITLE_Y], width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT do
        pdf.stroke_bounds
        pdf.text_box label, width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT, align: :center, valign: :center, style: :bold
      end
    end
  end

  def draw_hour_labels
    (START_HOUR..END_HOUR).each do |hour|
      # This is SO nasty. It sets how far down the page the hour
      # labels start counting--which was chosen arbitrarily.
      y = BODY_HEIGHT + TIME_SLOT_HEIGHT - hour * HOUR_HEIGHT
      [1,4].map {|column| column * COLUMN_WIDTH }.each do |x|
        label = (hour%12).to_s
        label = "12" if label == "0"
        pdf.bounding_box [x,y], width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT do
          pdf.text_box label, width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT, align: :right, valign: :center
        end
      end
    end
  end

  def draw_task_column_labels
      pdf.text_box "Tasks", at: [0, PAGE_HEIGHT], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
  end

  def draw_day_column_labels
    # TODO: SRPV. This is template/render code
    day_labels = (0...DAYS_PER_WEEK).map {|d| (date + d).strftime "%a   %-m/%-d" }

    day_labels.map.with_index {|label, i| [label, (TODO_COLUMNS+i)*COLUMN_WIDTH]}.each do |label, x|
      pdf.text_box label, at: [x,PAGE_HEIGHT], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
    end
  end

  def draw_labels
    draw_page_title
    with_font_size(HOURLY_LABEL_FONT_SIZE) do
      draw_hour_labels
      draw_task_column_labels
      draw_day_column_labels
    end
  end

  def draw_graph_paper
    with_thin_pen do
      with_light_pen do
        (0..PAGE_WIDTH).step(GRAPH_CELL_WIDTH) do |x|
          pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
        end

        (0..PAGE_HEIGHT).step(GRAPH_CELL_HEIGHT) do |y|
          pdf.stroke_line [0,y], [PAGE_WIDTH,y]
        end
      end
    end
  end

  def draw_octant_outlines
    with_thick_pen do
      (0..PAGE_WIDTH).step(PAGE_WIDTH/GRAPH_MAJOR_COLUMNS).each do |x|
        pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      (0..PAGE_HEIGHT).step(PAGE_HEIGHT/GRAPH_MAJOR_ROWS).each do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
    end
  end
end
