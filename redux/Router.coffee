dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

Router = (store, backToPath, selectors) ->

  stop = store.subscribe () ->
    { url, pathChanged, fromBackButton } = selectors

    unless url? and pathChanged? and fromBackButton?
      throw "url, pathChanged and fromBackButton must all be valid selectors"

    state = store.getState()

    if not pathChanged(state)
      return # I'm not allowing discrete history steps within one URL!

    if fromBackButton(state)
      return

    window.history.pushState null, null, addFirstSlash url state

  # do initial page load, without adding a history item
  store.dispatch backToPath dropFirstSlash window.location.pathname

  window.onpopstate = () ->
    store.dispatch backToPath dropFirstSlash window.location.pathname

  # return {stop} # TODO: make this detatch the onpopstate lister too
  return

module.exports = Router
