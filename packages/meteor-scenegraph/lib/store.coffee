Node = @Node

# The object store
@Store = Store = {}
Internals.Store = Store

# Set the functions that determine whether a modification is OK
Store.allow = (callbacks) ->
  # TODO
  # Store.collection.allow
  #   insert: callbacks.insert
  #   remove: callbacks.remove
  #   update: (userId, doc, fields, modifier) ->
  #     # Here the modifier should be of the form
  #     # {$set: {modified-fields}}
  #     callbacks.update(userId, doc, modifier.$set)

