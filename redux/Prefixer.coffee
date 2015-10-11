
prefixer = (PREFIX) ->
  prefix: (string) -> PREFIX + string
  unprefix: (prefixedString) ->
    if not prefixedString? or prefixedString.indexOf(PREFIX) is -1
      return null
    return prefixedString.substr PREFIX.length

module.exports = prefixer




console.assert prefixer('Rt$').prefix('a') is 'Rt$a', 'should add prefix correctly'
console.assert prefixer('Rt$').unprefix('Rt$a') is 'a', 'should remove prefix correctly'
console.assert prefixer('Rt$').unprefix('JKJADLJa') is null, 'shouldnt remove non prefix'
