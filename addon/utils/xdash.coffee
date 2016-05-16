`import Ember from 'ember'`
`import _ from 'lodash/lodash'`
`import {computedTask, computedPromise} from './computed-promise'`

{isBlank, isPresent, isArray, computed, A, get, set, getWithDefault} = Ember
{trimRight, tap, endsWith, isEqual, isFunction, isRegExp, has, isString, map, every, partial, partialRight, curry, flow, negate} = _

consumeEnd = (string, substr) ->
  if (isOk = endsWith(string, substr))
    string = trimRight string, substr
  [isOk, string, substr]

noMatchError = (value) -> "Nothing matched `#{value}`"
match = (value, [matcher, action], matchPairs...) ->
  throw noMatchError(value) unless action?
  [isEq, newVal] = matchEqual(matcher, value)
  if isEq
    action(newVal)
  else
    match(value, matchPairs...)

matchEqual = (matcher, value) ->
  return [true, value] if matcher is _
  return [matcher is value, value] if typeof matcher in ["number", "string"]
  return matcher(value) if isFunction(matcher)
  if isRegExp(matcher) and isString(value)
    results = matcher.exec(value) ? []
    return [isPresent(results), results]
  return [isEqual(matcher, value), value]

update = (obj, field, x, f) ->
  tap obj, (obj) ->
    set obj, field, if has(obj, field) then f(get obj, field) else x

genFun = -> yield return "autox"
isGenerator = (fn) ->
  if Function::isGenerator?
    fn?.isGenerator
  else
    fn?.constructor is genFun.constructor
isPromise = (x) -> isFunction(x?.then)
isObject = (x) -> x? and typeof x is "object"
hasFunctions = (x, fs...) -> x? and every map(fs, (f) -> x[f]), isFunction
modelChecks = [isPresent, negate(isArray), isObject, partialRight(hasFunctions, "get", "save")]
into = (x) -> (f) -> f x
isModel = flow into, partial(every, modelChecks)
isntModel = negate(isModel)
tapLog = (x) ->
  console.log x
  x
_computed =
  computedTask: computedTask
  computedPromise: computedPromise
  access: (objKey, memKey) ->
    computed objKey, memKey,
      get: ->
        if (key = @get memKey)?
          if (obj = @get objKey)?
            obj.get?(key) ? get(obj, key)

  apply: (keys..., f) ->
    computed keys...,
      get: -> 
        xs = map keys, @get.bind(@)
        f xs...
  match: (key, matchers...) ->
    computed key,
      get: ->
        boundMatchers = A(matchers).map ([matcher, action]) => [matcher, action.bind(@)] 
        match @get(key), boundMatchers...

_x = {
  match,
  update,
  tapLog,
  isGenerator,
  isPromise,
  consumeEnd,
  isntModel,
  isModel,
  isObject,
  hasFunctions, 
  computed: _computed
}

`export {_computed, _x}`
`export default _x`