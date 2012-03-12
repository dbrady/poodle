class Planner
  def self.draw(start_date, filename)
    start_date = self.rewind_to_monday start_date
    pdf = generate_planner_pdf start_date
    save_pdf pdf, filename
  end

  def self.save_pdf(pdf, filename)
    open_file(filename, 'w') do |file|
      file.write pdf.render
    end
  end

  # This is just a wrapper to File.open so we can test this class
  # without stubbing File.open itself (which other programs in the
  # testing ecosystem are using). A later refactoring could make this
  # filename -> file conversion explicit, and eliminate the need for a
  # stub altogether.
  def self.open_file(filename, mode, &block)
    File.open(filename, mode) do |file|
      yield file
    end
  end

  # Returns first Monday on or before start_date
  def self.rewind_to_monday(start_date)
    delta = start_date.wday - 1
    delta += 7 if delta < 0 # Sundays will advance the date by default
    start_date -= delta
  end

  def self.generate_planner_pdf(start_date)
    pdf = Prawn::Document.new page_layout: :landscape do
      # ======================================================================
      # Front Page

      # draw light horz lines--half-hour increments plus to-do list items
      line_width 0.1

      opacity 0.75 do
        y = 531
        while y > 0
          y-=9
          stroke_line [0,y], [720,y]
        end
      end

      line_width 0.2

      # ----------------------------------------------------------------------
      # Draw day boxes and outline
      # ----------------------------------------------------------------------
      # vertical lines at edges and between days
      (0..8).each do |i|
        x = i * (720/8.0)
        stroke_line [x,0], [x,540]
      end

      # vertical lines inside day lines for ticking of to-dos
      line_width 0.1
      (0..7).each do |i|
        x = 9 + i * (720/8.0)
        stroke_line [x,0], [x,522]
      end
      line_width 0.2

      # horizontal lines across top and bottom
      [0,540].each do |y|
        stroke_line [0,y], [720,y]
      end
      stroke_line [90,522], [720,522]

      # ----------------------------------------------------------------------
      # Draw labels
      # ----------------------------------------------------------------------

      # calculate dates for this planner
      end_date = start_date + 6
      label = start_date.strftime("%b %-d - ")
      label += end_date.strftime("%b ") if end_date.month != start_date.month
      label += end_date.strftime("%-d, %Y")

      # Draw main title label, e.g "Jan 30-Feb 5, 2012
      bounding_box [510, 562], width: 140, height: 18 do
        stroke_bounds
        text_box label, width: 140, height: 18, align: :center, valign: :center, style: :bold
      end

      # Draw hourly column label 8, 9, 10, etc in Monday and Thursday columns
      old_font_size = font_size
      font_size 8
      (8..20).each do |hour|
        [720/8.0, 4*(720/8.0)].each do |x|
          y = 531-18*hour
          label = (hour%12).to_s
          label = "12" if label == "0"
          bounding_box [x,y], width: 9, height: 18 do
            text_box label, width: 9, height: 18, align: :right, valign: :center
          end
        end
      end
      font_size = old_font_size

      # Draw day labels, e.g. "Mon 1/30", "Tue 1/31", "Wed 2/1" etc.
      days = (0..6).map {|d| (start_date + d).strftime("%a   %-m/%-d")}

      (0..7).each do |i|
        next if i.zero?
        x = i * 720/8.0
        y = 540
        text_box days[i-1], at: [x,y], height: 18, width: 90, align: :center, valign: :center, style: :bold
      end

      # ======================================================================
      # Back Page

      start_new_page

      # lightweight graph
      line_width 0.1

      opacity 0.75 do
        x = 0
        while x <= 720
          stroke_line [x,0], [x,540]
          x += 9
        end

        y = 0
        while y <= 540
          stroke_line [0,y], [720,y]
          y += 9
        end
      end

      # bounds
      line_width 0.2
      (0..4).each do |i|
        x = i * 720/4.0
        stroke_line [x,0], [x,540]
      end

      (0..2).each do |i|
        y = i * 540/2.0
        stroke_line [0,y], [720,y]
      end
    end
  end
end

