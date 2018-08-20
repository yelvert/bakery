module Bakery
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 0

    def to_s
      @to_s ||= [MAJOR, MINOR, PATCH].join('.')
    end
    module_function :to_s

  end
end
