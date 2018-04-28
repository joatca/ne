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

require "./ne/*"

# TODO: Write documentation for `Ne`
module Ne
  config = Config.new
  p = NEParser.new(config)
  begin
    p.parse(ARGV)
    puts p
  rescue e : ArgumentError
    STDERR.puts "#{PROGRAM_NAME}: #{e.message}"
  end
end
