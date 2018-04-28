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

  class NodeExpr

    getter nodes
    
    @nodes = Hash(String, Set(UInt32)).new { |h, prefix| h[prefix] = Set(UInt32).new }

    def initialize(@config : Config)
    end

    def parse(expr : String)
      @expr = expr
      if md = expr.match(/^@(\S*)/)
        scan_file(md[1])
        return md
      end
      if md = expr.match(/^(#{@config.prefix_re})(#{@config.digits_re})/)
        @nodes[md[1]] << md[2].to_u32
        return md
      end
      if md = expr.match(/^(#{@config.prefix_re})\[([-,[:digit:]]+)\]/)
        prefix = md[1]
        chunks = md[2].split(',')
        chunks.each do |chunk|
          case chunk
          when /^(#{@config.digits_re})$/
            @nodes[prefix] << $1.to_u32
          when /^(#{@config.digits_re})-(#{@config.digits_re})$/
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

    def scan_file(filename : String)
      if filename == ""
        scan_io(STDIN)
      else
        File.open(filename, "r") do |fio|
          scan_io(fio)
        end
      end
    end

    def scan_io(io : IO)
      io.each_line do |line|
        line.scan(/(#{@config.prefix_re})(#{@config.digits_re})/) do |match|
          @nodes[match[1]] << match[2].to_u32
        end
      end
    end
    
    def each_group
      @nodes.each do |prefix, numbers|
        yield prefix, numbers
      end
    end

    def add(other : NodeExpr)
      other.each_group do |prefix, numbers|
        @nodes[prefix] |= numbers
      end
      self
    end

    def difference(other : NodeExpr)
      other.each_group do |prefix, numbers|
        @nodes[prefix] -= numbers
      end
      self
    end

    def intersection(other : NodeExpr)
      self.each_group do |prefix, numbers|
        @nodes[prefix] &= other.nodes[prefix]
      end
      self
    end
    
    def range_to_s(s : UInt32, e : UInt32, io : IO)
      if s == e
        io.printf(@config.digit_format, s)
      else
        io.printf(@config.digit_format, s)
        io << '-'
        io.printf(@config.digit_format, e)
      end
    end
    
    def to_s(io : IO)
      if @config.compressed
        write_compressed(io)
      else
        write_uncompressed(io)
      end
    end

    def write_uncompressed(io : IO)
      first = true
      @nodes.each do |prefix, numbers|
        numbers.to_a.sort.each do |number|
          io << @config.node_sep unless first
          first = false
          io << prefix
          io.printf(@config.digit_format, number)
        end
      end
    end
    
    def write_compressed(io : IO)
      first = true
      @nodes.each do |prefix, numbers|
        io << @config.group_sep unless first
        io << @config.group_prefix
        next if numbers.size == 0
        io << prefix
        if numbers.size == 1
          io.printf(@config.digit_format, numbers.first)
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
