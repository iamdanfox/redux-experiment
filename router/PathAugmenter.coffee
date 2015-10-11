NestThunkCreator = require '../nest/NestThunkCreator'
DefaultPrefixer = require('../nest/MakePrefixer')('PA-')


wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner
wrapAction = (prefix) -> (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (unprefix) -> (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null


pathAugmenterFromPrefixer = ({prefix, unprefix}) ->
  return {
    unwrapState: unwrapState

    makeActionCreators: ({handlePath}) ->
      wrap: NestThunkCreator {unwrapState, wrapAction: wrapAction prefix}
      handlePath: handlePath

    extendReducer: (innerReducer, keyToMapperObject) ->
      extensionFromState = (innerState) ->
        extension = {}
        extension[key] = mapper(innerState) for key,mapper of keyToMapperObject
        return extension

      initialState = do ->
        innerInitialState = innerReducer undefined, {}
        return Object.assign {}, wrapState(innerInitialState), extensionFromState innerInitialState

      return (state = initialState, action) ->
        innerState = innerReducer unwrapState(state), unwrapAction(unprefix)(action) or {}
        return Object.assign wrapState(innerState), extensionFromState innerState
  }

pathAugmenter = pathAugmenterFromPrefixer DefaultPrefixer

module.exports = { pathAugmenterFromPrefixer, pathAugmenter }
