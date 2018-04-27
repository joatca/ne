# This file is part of ne, the node expression tool
# Copyright Fraser McCrossan <fraser@mccrossan.ca> 2018
# 
# ne is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ne is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ne.  If not, see <http://www.gnu.org/licenses/>.

module Ne

  enum Operator
    NONE
    UNION
    DIFFERENCE
    INTERSECTION
  end
    
  class NEParser

    CHAR_OPS = [ '+', '-', '^', ' ' ]

    PARSE_OPS = [
      { /^\s*\+\s*/, Operator::UNION },
      { /^\s*-\s*/, Operator::DIFFERENCE },
      { /^\s*\^\s*/, Operator::INTERSECTION },
      { /^\s+/, Operator::UNION },
    ]
          
    def initialize(@config : Config)
      @expr = NodeExpr.new(@config)
      @operator = Operator::UNION
    end

    def parse(ary : Enumerable(String))
      parse ary.join(" ")
    end
    
    def parse(s : String)
      # first clean up the string to make it easier to parse - we don't have a real parser yet
      clean = s.gsub(/^\s+/, "").gsub(/\s+$/, "").gsub(/\s{2,}/, " ")
      operator = Operator::UNION
      match = @expr.parse(clean)
      clean = match.post_match
      while clean.size > 0
        operator = Operator::NONE
        PARSE_OPS.each do |op|
          op_match = clean.match(op.first)
          if op_match
            clean = op_match.post_match
            operator = op.last
            break
          end
        end
        raise ArgumentError.new("syntax error at \"#{clean}\"") if operator == Operator::NONE
        next_expr = NodeExpr.new(@config)
        expr_match = next_expr.parse(clean)
        clean = expr_match.post_match
        case operator
        when Operator::UNION
          @expr.add(next_expr)
        when Operator::DIFFERENCE
          @expr.difference(next_expr)
        when Operator::INTERSECTION
          @expr.intersection(next_expr)
        end
      end
    end

    def to_s(io : IO)
      @expr.to_s(io)
    end
    
  end
  
end
