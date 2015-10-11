{ compose } = require 'redux'

dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

makeRouter = (config) ->
  {store, handlePopStatePath, pathFromReduxState, fromBackButton} = config
  unless store? and handlePopStatePath? and pathFromReduxState? and fromBackButton?
    console.error "missing configuration", config

  return router =
    handleWindowLocation: () ->
      store.dispatch handlePopStatePath dropFirstSlash window.location.pathname

    addPopStateListener: () ->
      window.addEventListener 'popstate', router.handleWindowLocation
      return () -> window.removeEventListener 'popstate', router.handleWindowLocation

    subscribeToStore: () ->
      path = pathFromReduxState store.getState()
      return store.subscribe () ->
        newPath = pathFromReduxState store.getState()
        pathChanged = newPath isnt path
        path = newPath

        if not pathChanged
          return # I'm not allowing discrete history steps within one URL!

        if fromBackButton store.getState()
          return

        window.history.pushState null, null, addFirstSlash newPath

startRouter = (options) ->
  {handleWindowLocation, addPopStateListener, subscribeToStore} = makeRouter options

  handleWindowLocation() # handle initial route
  removePopStateListener = addPopStateListener()
  unsubscribeFromStore = subscribeToStore()

  return {stopRouter: compose removePopStateListener, unsubscribeFromStore}



module.exports = { makeRouter, startRouter }
