{ compose } = require 'redux'

dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

makeRouter = (config) ->
  {store, handlePopStatePath, pathFromReduxState, pathChanged, fromBackButton} = config
  unless store? and handlePopStatePath? and pathFromReduxState? and pathChanged? and fromBackButton?
    console.error "missing configuration", config

  return router =
    handleWindowLocation: () ->
      store.dispatch handlePopStatePath dropFirstSlash window.location.pathname

    addPopStateListener: () ->
      window.addEventListener 'popstate', router.handleWindowLocation
      return () -> window.removeEventListener 'popstate', router.handleWindowLocation

    subscribeToStore: () ->
      return store.subscribe () ->
        state = store.getState()

        if not pathChanged(state)
          return # I'm not allowing discrete history steps within one URL!

        if fromBackButton(state)
          return

        window.history.pushState null, null, addFirstSlash pathFromReduxState state

startRouter = (options) ->
  {handleWindowLocation, addPopStateListener, subscribeToStore} = makeRouter options

  handleWindowLocation() # handle initial route
  removePopStateListener = addPopStateListener()
  unsubscribeFromStore = subscribeToStore()

  return {stopRouter: compose removePopStateListener, unsubscribeFromStore}



module.exports = { makeRouter, startRouter }
