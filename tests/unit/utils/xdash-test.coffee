`import _x from 'ember-autox-core/utils/xdash'`
`import { module, test } from 'qunit'`
`import _ from 'lodash/lodash'`

module 'Unit | Utility | xdash'

matchTest = (x) ->
  _x.match x,
    ["dog", -> "dog"],
    [/(beaver|rodent)/, ([_, x]) -> x],
    [_, -> "xxx"]

test 'it works', (assert) ->
  assert.equal matchTest("dog"), "dog"
  assert.equal matchTest("beaver"), "beaver"
  assert.equal matchTest("rodent"), "rodent"
  assert.equal matchTest("beavers and rodents"), "beaver"
  assert.equal matchTest("honey smack"), "xxx"

class PseudoModel
  get: ->
  save: ->

class PseudoPromise
  then: ->
  catch: ->

test 'isModel', (assert) ->
  assert.ok _x.isModel(new PseudoModel())
  assert.notOk _x.isModel(1)
  assert.notOk _x.isModel("djfasd")
  assert.notOk _x.isModel([2])
  assert.notOk _x.isModel([])
  assert.notOk _x.isModel({})
  assert.notOk _x.isModel(new Date())
  assert.notOk _x.isModel([2])
  assert.notOk _x.isModel(new PseudoPromise())
