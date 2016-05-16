`import Ember from 'ember'`
`import DS from 'ember-data'`
`import {computedTask} from 'ember-autox-core/utils/computed-promise'`
`import { module, test } from 'qunit'`

{A, computed, RSVP, run} = Ember
{PromiseArray} = DS
module 'Unit | Utility | computed promise'

wait = (n) ->
  new RSVP.Promise (resolve) ->
    run.later @, resolve, n

Shop = Ember.Object.extend
  rawHistories: A []
  histories: computed "rawHistories.[]", ->
    PromiseArray.create
      promise: RSVP.resolve @get "rawHistories"
  canOpen: computedTask "histories.firstObject", ->
    @get "histories"
    .then (histories) ->
      histories.get("firstObject")
    .then (history) -> 
      history is "approved"
  addHistory: (history) ->
    hs = @get("rawHistories")
    new RSVP.Promise (resolve) =>
      f = (h) -> 
        resolve hs.unshiftObject h
      run.later @, f, history, 15

# Replace this with your real tests.
test 'it works', (assert) ->
  Ember.run ->
    shop = Shop.create()
    assert.notOk shop.canOpenTask, "we should not have the task on here yet"
    assert.notOk shop.get("canOpen"), "we should not be able to open"
    assert.ok shop.canOpenTask, "we should have created a task on this object"
    shop.addHistory("approved")
    .then ->
      wait 1
    .then ->
      assert.ok shop.get("canOpen"), "after receiving approval, we should be able to open"
      wait 100
    .then ->
      assert.ok true, "ends"
