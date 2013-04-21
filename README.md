# Poodle

David Brady's Personal Day Planner Building Script. Generates a 1-page
(2-sided) PDF of a 7-day planner sheet for time management.

Poodle was originally going to be a generic drawing language, and I'd
still like to grow it to get there. But right now the best and only
use case I have for it is to draw a planner sheet and emit it as PDF.

Going forward, I hope to develop using these principles:

* Starting small is important, but being growable is essential.
* Avoid creating a full drawing framework straight out of the gate.
* DO make it easy to modify the fundamental layout of the planner
  sheets. Right now the layout is deeply and implicitly embedded in
  the code. I want to shrink margins, move boxes around, and
  eventually create punchouts with other drawings inside them (like
  mini calendars, workout tracking charts, food diaries, etc)
* Rework to solid OO principles, especially SRP and separating drawing
  primitives from the notion of drawing a planner sheet
* Rework to leverage Ruby 2.0 better
* Move from RSpec to MiniTest, especially while the test suite is so
  small
* Avoid trying to abstract away Prawn, unless it makes sense. It's a
  year later and I still don't have a User Story that says "stop using
  Prawn". :-) *DO* remember, however, that Prawn is just there to give
  me clean and crisp drawings on the printer. I played with SVG
  briefly, but that would have required starting from scratch. I could
  still go back to it if it made sense but right now creating a 2-page
  PDF is a pretty easy API to get these drawings to shoot out of a
  printer's paper pooper.

Long-term:

* I'd like to expand the planner portion into more of a PIM, probably
  meaning pulling it out of Poodle entirely, and having a TODO/ICAL
  program that uses Poodle to generate planner sheets.
* Investigate other drawing backends. There really are a dearth of
  them. LaTeX probably has the horsepower to do it, but may need a
  whole drawing engine on top of it, dunno.

For now I think the plan will be to push SRP hard, and try to push
things down. Right now planner.rb knows how to tell Prawn how to draw
a planner sheet, when all it should really care about is the date; I
can push stuff down so that some kind of planner sheet draw-er can
order Prawn around, then push stuff down again, etc.
