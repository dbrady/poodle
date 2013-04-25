# Poodle

David Brady's Personal Day Planner Building Script. Generates a 1-page
(2-sided) PDF of a 7-day planner sheet for time management.

Poodle was originally going to be a generic drawing language, and I'd
still like to grow it to get there. But right now the best and only
use case I have for it is to draw a planner sheet and emit it as PDF.

Going forward, I hope to develop using these principles:

* WORSHIP AT THE (UNHOLY) ALTAR OF INCREMENTALISM. This script worked
  from the get-go. It has worked during every phase of refactoring. It
  shall continue to do so. This is my watchword: NO REWRITES FROM
  SCRATCH! This started out as a single, 127-line script with no
  methods and no classes, but by the grace of all that is good and/or
  the connivance of the darkest of all unholies, IT WORKED. So: Cuss
  at my horrible code all you want; take comfort in the knowledge that
  not only do I deserve your wrath, but that I *know* I deserve your
  wrath. This code is bad and I should and do feel bad. But to
  paraphrase Spock's tear-jerking line from the Star Trek reboot:
  "This code has, and always be, WORKY." Refactor incrementally is
  what I'm saying here, no matter how terrifyingly many iterations are
  obviously necessary to reach any semblance of total non-poo.
* Starting small is important, but being growable is essential. Factor
  out dependencies as much as possible. Inject them when we can,
  isolate them when we can't. Figure out what things change, what
  things don't, and reverse dependencies if necessary to ensure that
  things generally depend on things that change less than they do.
* Avoid creating a full drawing framework straight out of the
  gate. This has been my analysis paralysis poison for over a year--I
  don't want to touch this at all because I know I'll have to write a
  whole drawing language. Bah. Move forward as far as possible without
  writing such a thing. Only when writing a drawing language becomes
  the next obvious needed thing AND the code is simple enough to make
  this no longer a daunting task... THEN I can do it.
* DO make it easy to modify the fundamental layout of the planner
  sheets. Right now the layout is deeply and implicitly embedded in
  the code. I want to shrink margins, move boxes around, and
  eventually create punchouts with other drawings inside them (like
  mini calendars, workout tracking charts, food diaries, etc). So in
  other words, layouts and templates are highly subject to change,
  therefore they should not be embedded in anything. Nothing should
  depend on them, meaning nothing else should have to change if I want
  to change a layout.
* Rework to solid OO principles, especially SRP and separating drawing
  primitives from the notion of drawing a planner sheet.
* Rework to leverage Ruby 2.0 better.
* Move from RSpec to MiniTest, especially while the test suite is so
  small.
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
