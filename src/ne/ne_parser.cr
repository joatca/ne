# This file is part of ne, the node expression tool
# Copyright Fraser McCrossan <fraser@mccrossan.ca> 2018
# 
# Foobar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

module Ne

  enum Operator
    UNION
    DIFFERENCE
    INTERSECTION
  end
    
  class NEParser

    CHAR_OPS = {
      '+' => UNION,
      '-' => DIFFERENCE,
      '^' => INTERSECTION,
    }

    RE_OPS = CHAR_OPS.map { |char, op| [ /\s+(#{char})\s+/, op ] }.to_h

    ALL_OPS = Regex.union(RE_OPS)
      
    def initialize
      @ne = NodeExpr.new
      @operator = UNION
    end

    def parse(ary : Enumerable(String))
      parse ary.join(" ")
    end
    
    def parse(s : String)
      # first clean up the string to make it easier to parse - we don't have a real parser yet
      clean = s.gsub(/^\s+/, "").gsub(/\s+$/, "").gsub(/\s{2,}/, " ")
      match = @ne.parse(clean)
      pos = 0
    end
    
  end
end
