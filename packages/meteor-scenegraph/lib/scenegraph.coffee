Node = @Node

# Namespaces
# ==========

SG.Types = Type.Types

# Functions
# =========

# Register a new type
SG.type = (name, inheritance, fields) ->
  Type.register name, inheritance, fields

SG.factory = Type.factory

class SG.Scene
  constructor: (scene_id) ->
    @scene_id = scene_id

  # Add objects to the scene graph
  add: (object) ->
    Node.manage object, @scene_id
    Store.manage object
  
  # Share a set of object updates
  update: (object, fields = true) ->
    unless Node.managed object
      throw new SG.Error "Tried to update unmanaged object"
    Store.update Node.scene_id(object), Node.id(object), Node.some_fields(object, fields)
  
  # Remove objects from the scene
  remove: (object) ->
    unless Node.managed object
      throw new SG.Error "Tried to remove unmanaged object"
    Store.remove Node.scene_id(object), Node.id(object)

  # Subscribe to updates
  subscribe: ->
    Store.subscribe @scene_id


