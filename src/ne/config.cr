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

require "option_parser"

module Ne

  class Config

    getter compressed, group_sep, group_prefix, node_sep
    getter prefix_re, digits_re
    
    def initialize
      @group_sep = " " # when printing multiple prefix groups
      @group_prefix = "" # print before each prefix group
      @node_sep = "\n" # when printing individual nodes in uncompressed mode
      @compressed = true # show as foo[1-5] or foo1 foo2 foo3 foo4 foo5
      min_prefix = 1_u32 # min prefix length
      max_prefix = 5_u32 # max prefix length
      min_digits = 1_u32
      max_digits = 5_u32

      OptionParser.parse! do |parser|
        parser.banner = "Usage: #{PROGRAM_NAME} [options] node-expression..."
        parser.on("-gSEPARATOR", "output node groups separated by SEPARATOR") { |g|
          @compressed = true
          @group_sep = g
        }
        parser.on("-pPREFIX", "print PREFIX before each node group") { |p|
          @group_prefix = p
        }
        parser.on("-n", "output individual nodes separated by newlines") {
          @compressed = false
          @node_sep = "\n"
        }
        parser.on("-sSEPARATOR", "output individual nodes separated by SEPARATOR") { |s|
          @compressed = false
          @node_sep = s
        }
        parser.on("--min-prefix=LENGTH", "minimum node name prefix recognized is LENGTH (default #{min_prefix})") { |l|
          min_prefix = l.to_u32
        }
        parser.on("--max-prefix=LENGTH", "maximum node name prefix recognized is LENGTH (default #{max_prefix})") { |l|
          max_prefix = l.to_u32
        }
        parser.on("--min-digits=LENGTH", "minimum node name digits recognized is LENGTH (default #{min_digits})") { |l|
          min_digits = l.to_u32
        }
        parser.on("--max-digits=LENGTH", "maximum node name digits recognized is LENGTH (default #{max_digits})") { |l|
          max_digits = l.to_u32
        }
        parser.on("-sSEPARATOR", "output individual nodes separated by SEPARATOR") { |s|
          @compressed = false
          @node_sep = s
        }
        parser.on("-h", "--help", "Show this help") {
          puts parser
          exit 0
        }
        parser.invalid_option { |o|
          STDERR.puts "#{PROGRAM_NAME}: unknown option #{o}"
          STDERR.puts parser
          exit 1
        }
        parser.missing_option { |m|
          STDERR.puts "#{PROGRAM_NAME}: option #{m} requires an argument"
          STDERR.puts parser
          exit 1
        }
      end
      @prefix_re = /[[:alpha:]]{#{min_prefix},#{max_prefix}}/
      @digits_re = /[[:digit:]]{#{min_digits},#{max_digits}}/
    end
    
  end
  
end
