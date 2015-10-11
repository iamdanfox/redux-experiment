
makePrefixer = (PREFIX) ->
  prefix: (string) -> PREFIX + string
  unprefix: (prefixedString) ->
    if not prefixedString? or prefixedString.indexOf(PREFIX) isnt 0
      return null
    return prefixedString.substr PREFIX.length

module.exports = makePrefixer




console.assert makePrefixer('Rt$').prefix('a') is 'Rt$a', 'should add prefix correctly'
console.assert makePrefixer('Rt$').unprefix('Rt$a') is 'a', 'should remove prefix correctly'
console.assert makePrefixer('PREFIX$').unprefix('DOUBLEPREFIX$a') is null, 'should ignore matches in the middle'
console.assert makePrefixer('Rt$').unprefix('JKJADLJa') is null, 'shouldnt remove non prefix'
console.assert makePrefixer('Rt$').unprefix(null) is null, 'shouldnt freak out with a null argument'
