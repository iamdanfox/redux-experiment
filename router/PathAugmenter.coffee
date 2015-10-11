NestThunkCreator = require '../nest/NestThunkCreator'
DefaultPrefixer = require('../nest/MakePrefixer')('PA-')
{ wrapState, unwrapState, wrapAction, unwrapAction } = require '../nest/Wrappers'


makePathAugmenter = ({prefix, unprefix, nestActionCreator}) ->
  return {
    unwrapState: unwrapState

    makeActionCreators: ({handlePath}) ->
      innerAction: nestActionCreator {unwrapState, wrapAction: wrapAction prefix}
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

pathAugmenter = makePathAugmenter
  prefix: DefaultPrefixer.prefix
  unprefix: DefaultPrefixer.unprefix
  nestActionCreator: NestThunkCreator

module.exports = { makePathAugmenter, pathAugmenter }
