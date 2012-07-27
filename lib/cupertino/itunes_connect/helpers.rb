# Monkey Patch Commander::UI to alias password to avoid conflicts
module Commander::UI
  alias :pw :password
end

class String
  include Term::ANSIColor
end
