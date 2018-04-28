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

    @group_sep : String
    @group_prefix : String
    @node_sep : String
    @compressed : Bool    

    getter compressed, group_sep, group_prefix, node_sep
    getter prefix_re, digits_re
    getter digit_format
    
    def initialize
      # when printing multiple prefix groups
      @group_sep = ENV.fetch("NE_GROUP_SEPARATOR", " ")
      # print before each prefix group
      @group_prefix = ENV.fetch("NE_GROUP_PREFIX", "")
      # when printing individual nodes in uncompressed mode
      @node_sep = ENV.fetch("NE_NODE_SEPARATOR", "\n")
      # show as foo[1-5] or foo1 foo2 foo3 foo4 foo5
      @compressed = ENV.has_key?("NE_EXPANDED_OUTPUT") ? false : true
      min_prefix = begin
                     ENV.fetch("NE_MIN_PREFIX_LENGTH", "").to_u32
                   rescue ArgumentError
                     1_u32
                   end
      max_prefix = begin
                     ENV.fetch("NE_MAX_PREFIX_LENGTH", "").to_u32
                   rescue ArgumentError
                     5_u32
                   end
      min_digits = begin
                     ENV.fetch("NE_MIN_DIGITS", "").to_u32
                   rescue ArgumentError
                     1_u32
                   end
      max_digits = begin
                     ENV.fetch("NE_MAX_DIGITS", "").to_u32
                   rescue ArgumentError
                     5_u32
                   end
      pad_digits = begin
                     ENV.fetch("NE_PAD_DIGITS", "").to_u32
                   rescue ArgumentError
                     1_u32
                   end

      OptionParser.parse! do |parser|
        parser.banner = "Usage: #{PROGRAM_NAME} [options] node-expression...\n\nOption defaults can be set with the indicated environment variables\n"
        parser.on("-gSEPARATOR", "output node groups separated by SEPARATOR (NE_GROUP_SEPARATOR)") { |g|
          @compressed = true
          @group_sep = g
        }
        parser.on("-pPREFIX", "print PREFIX before each node group (NE_GROUP_PREFIX)") { |p|
          @group_prefix = p
        }
        parser.on("-e", "output individual nodes instead of node expressions (NE_EXPANDED_OUTPUT=1)") {
          @compressed = false
        }
        parser.on("-sSEPARATOR", "in expanded output, change newlines to SEPARATOR (NE_NODE_SEPARATOR)") { |s|
          @node_sep = s
        }
        parser.on("-dDIGITS", "pad output node names to at least DIGITS digits (NE_PAD_DIGITS)") { |d|
          pad_digits = d.to_u32
        }
        parser.on("--min-prefix=LENGTH", "minimum node name prefix recognized is LENGTH (NE_MIN_PREFIX_LENGTH, default #{min_prefix})") { |l|
          min_prefix = l.to_u32
        }
        parser.on("--max-prefix=LENGTH", "maximum node name prefix recognized is LENGTH (NE_MAX_PREFIX_LENGTH, default #{max_prefix})") { |l|
          max_prefix = l.to_u32
        }
        parser.on("--min-digits=LENGTH", "minimum node digits recognized is LENGTH (NE_MIN_DIGITS, default #{min_digits})") { |l|
          min_digits = l.to_u32
        }
        parser.on("--max-digits=LENGTH", "maximum node digits recognized is LENGTH (NE_MAX_DIGITS, default #{max_digits})") { |l|
          max_digits = l.to_u32
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
      @digit_format = "%0#{pad_digits}d"
    end
    
  end
  
end
