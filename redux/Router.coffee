dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

Router = (store, backToPath) ->

  stop = store.subscribe () ->
    { url, pathChanged, fromBackButton } = store.getState()

    unless url? and pathChanged? and fromBackButton?
      throw "url, pathChanged and fromBackButton must all be non-null fields on the store"

    if not pathChanged
      return # I'm not allowing discrete history steps within one URL!

    if fromBackButton
      return

    window.history.pushState null, null, addFirstSlash(url)

  # do initial page load, without adding a history item
  store.dispatch backToPath dropFirstSlash window.location.pathname

  window.onpopstate = () ->
    store.dispatch backToPath dropFirstSlash window.location.pathname

  return {stop}

module.exports = Router
