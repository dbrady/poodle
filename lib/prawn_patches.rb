module Prawn
  class Document
    # Fix POLS violation in Prawn. transparent(1.0) is fully opaque,
    # not transparent, while transparent(0.0) is fully transparent,
    # not opaque. Add an "opacity" method so I can set the opacity
    # correctly.
    #--
    # TODO: For the sake of "Exemplary" code I probably should either
    # remove the transparent method, or change it to invert its
    # parameter so that it works the way one would expect.
    alias :opacity :transparent
  end
end
