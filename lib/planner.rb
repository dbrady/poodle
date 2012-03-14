class Planner
  # Prawn-specific page layout units
  PAGE_WIDTH=720
  PAGE_HEIGHT=540
  TIME_SLOT_HEIGHT=9
  HEADER_HEIGHT=18
  CHECK_COLUMN_WIDTH=9
  TITLE_LABEL_WIDTH=140
  TITLE_LABEL_HEIGHT=18
  TITLE_X=510
  TITLE_Y=PAGE_HEIGHT+TITLE_LABEL_HEIGHT+4

  # Prawn-specific appearance characteristics
  THICK_LINE_WIDTH=0.2
  THIN_LINE_WIDTH=0.1
  LIGHT_LINE_OPACITY=0.75
  HOURLY_LABEL_FONT_SIZE=8

  # Some useful derived constants
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

  attr_reader :pdf

  def self.create(start_date, filename)
    File.open(filename, "w") do |file|
      Planner.new(start_date).generate_into(file)
    end
  end

  def initialize(start_date)
    @start_date = start_date.beginning_of_workweek
  end

  def generate_into(file)
    generate_pdf
    write_to file
  end

  def generate_pdf
    @pdf = Prawn::Document.new page_layout: :landscape
    generate_front_page
    generate_back_page
    @pdf
  end

  def write_to(file)
    file.write pdf.render
  end

  def date_label_for_week
    end_date = @start_date + DAYS_PER_WEEK-1
    label = @start_date.strftime("%b %-d - ")
    label += end_date.strftime("%b ") if end_date.month != @start_date.month
    label += end_date.strftime("%-d, %Y")
  end

  def use_thick_pen
    pdf.line_width THICK_LINE_WIDTH
  end

  def use_thin_pen
    pdf.line_width THIN_LINE_WIDTH
  end

  def generate_front_page
    # draw light horz lines--half-hour increments plus to-do list items
    use_thin_pen
    pdf.opacity LIGHT_LINE_OPACITY do
      (0..BODY_HEIGHT).step(TIME_SLOT_HEIGHT) do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
    end

    # ----------------------------------------------------------------------
    # Draw day boxes and outline
    # ----------------------------------------------------------------------
    # vertical lines at edges and between days
    use_thick_pen
    (0..PAGE_WIDTH).step(COLUMN_WIDTH) do |x|
      pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
    end

    # vertical lines inside day lines for ticking of to-dos
    use_thin_pen
    (0...PAGE_WIDTH).step(COLUMN_WIDTH).map {|i| i + CHECK_COLUMN_WIDTH }.each do |x|
      pdf.stroke_line [x,0], [x,BODY_HEIGHT]
    end

    # horizontal lines across top and bottom
    use_thick_pen
    [0,PAGE_HEIGHT].each do |y|
      pdf.stroke_line [0,y], [PAGE_WIDTH,y]
    end
    pdf.stroke_line [COLUMN_WIDTH,BODY_HEIGHT], [PAGE_WIDTH,BODY_HEIGHT]

    # ----------------------------------------------------------------------
    # Draw labels
    # ----------------------------------------------------------------------

    # Draw main title label, e.g "Jan 30-Feb 5, 2012
    label = date_label_for_week

    pdf.bounding_box [TITLE_X, TITLE_Y], width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT do
      pdf.stroke_bounds
      pdf.text_box label, width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT, align: :center, valign: :center, style: :bold
    end

    # Draw hourly column label 8, 9, 10, etc in Monday and Thursday columns
    old_font_size = pdf.font_size
    pdf.font_size HOURLY_LABEL_FONT_SIZE
    (START_HOUR..END_HOUR).each do |hour|
      # This is SO nasty. It sets how far down the page the hour
      # labels start counting--which was chosen arbitrarily.
      y = (BODY_HEIGHT+TIME_SLOT_HEIGHT)-hour*HOUR_HEIGHT
      [1,4].map {|column| column * COLUMN_WIDTH }.each do |x|
        label = (hour%12).to_s
        label = "12" if label == "0"
        pdf.bounding_box [x,y], width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT do
          pdf.text_box label, width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT, align: :right, valign: :center
        end
      end
    end

    # Label the Tasks column
    pdf.text_box "Tasks", at: [0, PAGE_HEIGHT], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold

    # Draw day labels, e.g. "Mon 1/30", "Tue 1/31", "Wed 2/1" etc.
    day_labels = (0...DAYS_PER_WEEK).map {|d| (@start_date + d).strftime("%a   %-m/%-d")}

    day_labels.map.with_index {|label, i| [label, (TODO_COLUMNS+i)*COLUMN_WIDTH]}.each do |label, x|
      pdf.text_box label, at: [x,PAGE_HEIGHT], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
    end

    pdf.font_size = old_font_size
  end

  def generate_back_page
    pdf.start_new_page

    # lightweight graph
    use_thin_pen

    pdf.opacity LIGHT_LINE_OPACITY do
      (0..PAGE_WIDTH).step(GRAPH_CELL_WIDTH) do |x|
        pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      (0..PAGE_HEIGHT).step(GRAPH_CELL_HEIGHT) do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
    end

    # bounds
    use_thick_pen
    0.upto(GRAPH_MAJOR_COLUMNS).map { |i| i * PAGE_WIDTH/GRAPH_MAJOR_COLUMNS }.each do |x|
      pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
    end

    0.upto(GRAPH_MAJOR_ROWS).map {|i| i * PAGE_HEIGHT/GRAPH_MAJOR_ROWS }.each do |y|
      pdf.stroke_line [0,y], [PAGE_WIDTH,y]
    end
  end
end

