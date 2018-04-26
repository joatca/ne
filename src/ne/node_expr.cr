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

  class NodeExpr

    @nodes = Hash(String, Set(UInt32)).new { |h, prefix| h[prefix] = Set(UInt32).new }

    def initialize
    end

    def initialize(expr : String)
      parse(expr)
    end
    
    def parse(expr : String)
      @expr = expr
      if md = expr.match(/^([[:alpha:]]{1,9})([[:digit:]]{1,9})/)
        @nodes[$1] << $2.to_u32
        return md
      end
      if md = expr.match(/^([[:alpha:]]{1,9})\[([-,[:digit:]]+)\]/)
        prefix = $1
        chunks = $2.split(',')
        chunks.each do |chunk|
          case chunk
          when /^([[:digit:]]{1,9})$/
            @nodes[prefix] << $1.to_u32
          when /^([[:digit:]]{1,9})-([[:digit:]]{1,9})$/
            s, e = $1.to_u32, $2.to_u32
            raise ArgumentError.new("first number in range #{chunk} in \"#{expr}\" is greater than second") if s > e
            (s..e).each { |num| @nodes[prefix] << num }
          else
            raise ArgumentError.new("invalid expression chunk \"#{chunk}\" in \"#{expr}\"")
          end
        end
        return md
      else
        raise ArgumentError.new("invalid node expression \"#{expr}\"")
      end
    end

    def each_group
      @nodes.each do |prefix, numbers|
        yield prefix, numbers
      end
    end

    def +(other : NodeExpr)
      other.each_group do |prefix, numbers|
        numbers.each do |number|
          @nodes[prefix] << number
        end
      end
      self
    end

    def -(other : NodeExpr)
      other.each_group do |prefix, numbers|
        @nodes[prefix] -= numbers
      end
      self
    end
    
    def range_to_s(s : UInt32, e : UInt32, io : IO)
      if s == e
        io << s
      else
        io << s << "-" << e
      end
    end
    
    def to_s(io : IO)
      first = true
      @nodes.each do |prefix, numbers|
        io << ' ' unless first
        next if numbers.size == 0
        io << prefix
        if numbers.size == 1
          io << numbers.first
        else
          io << '['
          sequence = numbers.to_a.sort
          range_start = range_end = sequence[0]
          sequence[1..-1].each do |num|
            if num > range_end + 1
              # we've reached the end of the previous run, print it out
              range_to_s(range_start, range_end, io)
              io << ','
              range_start = range_end = num
            else
              range_end = num
            end
          end
          range_to_s(range_start, range_end, io)
          io << ']'
        end
        first = false
      end
    end
  end
  
end
