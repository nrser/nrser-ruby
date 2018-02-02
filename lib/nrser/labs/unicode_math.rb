module NRSER
  module UnicodeMath
    SET_STARTS = {
      bold: {
        upper: '1D400',
        lower: '1D41A',
      },
      
      bold_script: {
        upper: '1D4D0',
        lower: '1D4EA',
      },
    }
    
    class CharacterTranslator
      def initialize name, upper_start, lower_start
        @name = name
        @upper_start = upper_start
        @lower_start = lower_start
      end
      
      def translate_char char
        upper_offset = char.ord - 'A'.ord
        lower_offset = char.ord - 'a'.ord
        
        if upper_offset >= 0 && upper_offset < 26
          [ @upper_start.hex + upper_offset ].pack "U"
        elsif lower_offset >= 0 && lower_offset < 26
          [ @lower_start.hex + lower_offset ].pack "U"
        else
          char
        end
      end
      
      def translate string
        string.each_char.map( &method( :translate_char ) ).join
      end
      
      alias_method :[], :translate
    end
    
    def self.[] name
      name = name.to_sym
      starts = SET_STARTS.fetch name
      CharacterTranslator.new name, starts[:upper], starts[:lower]
    end
  end
end