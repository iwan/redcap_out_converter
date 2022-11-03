module RowsSeparator
  # RowsSeparator::LIST
  # RowsSeparator::CR

  def select(code)
    LIST.find{|e| e.code==code}
  end

  class << self
    include RowsSeparator
  end

  class CR # carriage return
    class << self
      def name
        'Carriage Return (Legacy Mac)'
      end

      def code
        'cr'
      end

      def char
        "\r"
      end
    end
  end

  class LF # Line feed
    class << self
      def name
        'Line feed (Unix/Linux)'
      end

      def code
        'lf'
      end

      def char
        "\n"
      end
    end
  end

  class CRLF # Windows
    class << self
      def name
        'CRLF (Windows)'
      end

      def code
        'crlf'
      end

      def char
        "\r\n"
      end
    end
  end

  LIST = [CR, LF, CRLF]
end



    # ROWS_SEP = { cr: "\r", lf: "\n", crlf: "\r\n" }
    # COLS_SEP = { tab: "\t", comma: ",", semicolon: ";" }
