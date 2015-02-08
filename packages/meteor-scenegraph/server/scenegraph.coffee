# Allow publication of a scene graph
SG.publish = (callback) ->
  Store.publish callback

# Allow modifications to a scene graph
SG.allow = Store.allow
