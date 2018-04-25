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

require "./ne/*"

# TODO: Write documentation for `Ne`
module Ne
  puts NodeExpr.new("foo[1-5]") + NodeExpr.new("foo[2,8,10,11]")
  puts NodeExpr.new("foo[1,3-5,8,9,10]") - NodeExpr.new("foo[4-8]")
end
