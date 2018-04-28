# ne

ne manipulates "node expressions", which are commonly used in
clustered systems to represent groups of nodes. For example, nodes 1
through 5 and 8 in the "foo" cluster would be written
"foo[1-5,8]". Single node names can be written either as "foo123" or
"foo[123]". Note that the values within [] are *not* character
sequences like in regular expressions, they are comma-separated ranges
of decimal numbers.

## Installation

Install Crystal per these instructions:
https://crystal-lang.org/docs/installation/

$ crystal build ne.cr --release

## Usage

By default `ne` accepts node expressions as arguments separated by
operators and outputs the result as an optimal node expression:

    $ ne foo[1,2,4,5,6,8]
    foo[1-2,4-6,8]

"+" means set union, overlapping ranges will be merged:

    $ ne foo[1-5] + foo[4-8]
    foo[1-8]

"+" is implied so `foo[1-5]+foo[4-8]` and `foo[1-5] foo[4-8]` are equivalent.

Spaces are only significant when the operator is implied. `foo[1-4]+foo[4-8]` and `foo[1-4] + foo[4-8]` are equivalent but `foo[1-4]foo[4-8]` is illegal.

"-" means set difference (it's legal to subtract something that's not
in the first expression):

    $ ne foo[1-8] - foo[6-12]
    foo[1-5]

"^" means the intersection of two expressions: nodes that are in both:

    $ ne foo[1-12] ^ foo[8-20]
    foo[8-12]

Expressions can be chained, and are evaluated strictly left-to-right
without precedence:

    $ ne foo[1-12] + foo[8-20] - foo[6-14]
    foo[1-5,15-20]

Change the group separator:

    $ ne -g, foo[1-5] bar[1-5]
    foo[1-5],bar[1-5]

(Or use environment variable `NE_GROUP_SEPARATOR`.)

You can output results as individual node names ("expanded"). For
newline separated:

    $ ne -e foo[50-54]
    foo50
    foo51
    foo52
    foo53
    foo54

(Or set environment variable `NE_EXPANDED_OUTPUT=something`.)

Or use a specific separator:

    $ ne -e -s, foo[50-54]
    foo50,foo51,foo52,foo53,foo54

(Or use environment variable `NE_NODE_SEPARATOR`.)

Multiple node name prefixes are supported:

    $ ne foo[1-5] + foo[4-8] + bar[6-10]
    foo[1-8] bar[6-10]

You can output an arbitrary prefix before each group (useful with pdsh):

    $ ne -p"-w " foo[1-5] + bar[6-10]
    -w foo[1-5] -w bar[6-10]

(Or use environment variable `NE_GROUP_PREFIX`.)

Pad up to a minimum number of digits:

    $ ne -d4 foo[1-5]
    foo[0001-0005]

(Or use environment variable `NE_PAD_DIGITS`.)

"@" reads a file or standard input, scanning arbitrary text
looking for words that look like node names (this can obviously be
unreliable) and returns the union:

    $ echo "this is a line that contains the node names foo12 and foo13" | ne @
    foo[12-13]

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/joatce/ne/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[joatca]](https://github.com/joatca) Fraser McCrossan - creator, maintainer
