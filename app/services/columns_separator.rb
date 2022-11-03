module ColumnsSeparator
  # ColumnsSeparator::LIST
  # ColumnsSeparator::Tab

  def select(code)
    LIST.find{|e| e.code==code}
  end

  class << self
    include ColumnsSeparator
  end


  class Tab
    class << self
      def name
        'Tab'
      end

      def code
        'tab'
      end

      def char
        "\t"
      end
    end
  end

  class Comma
    class << self
      def name
        'Comma'
      end

      def code
        'comma'
      end

      def char
        ","
      end
    end
  end

  class Semicolon
    class << self
      def name
        'Semicolon'
      end

      def code
        'semicolon'
      end

      def char
        ";"
      end
    end
  end

  LIST = [ Tab, Comma, Semicolon ]
end
