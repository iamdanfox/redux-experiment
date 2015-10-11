
prefixer = (PREFIX) ->
  prefix: (string) -> PREFIX + string
  unprefix: (prefixedString) ->
    if not prefixedString? or prefixedString.indexOf(PREFIX) isnt 0
      return null
    return prefixedString.substr PREFIX.length

module.exports = prefixer




console.assert prefixer('Rt$').prefix('a') is 'Rt$a', 'should add prefix correctly'
console.assert prefixer('Rt$').unprefix('Rt$a') is 'a', 'should remove prefix correctly'
console.assert prefixer('PREFIX$').unprefix('DOUBLEPREFIX$a') is null, 'should ignore matches in the middle'
console.assert prefixer('Rt$').unprefix('JKJADLJa') is null, 'shouldnt remove non prefix'
console.assert prefixer('Rt$').unprefix(null) is null, 'shouldnt freak out with a null argument'
