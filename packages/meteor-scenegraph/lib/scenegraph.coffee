Node = @Node

# Namespaces
# ==========

SG.Types = Type.Types

# Functions
# =========

# Register a new type
SG.type = (name, inheritance, fields) ->
  Type.register name, inheritance, fields

class SG.Scene
  constructor: (scene_id) ->
    @scene_id = scene_id

  # Add objects to the scene graph
  add: (object) ->
    Node.manage @scene_id, object
    Store.insert object
  
  # Share a set of object updates
  update: (object, fields) ->
    unless Node.managed object
      throw new SG.Error "Tried to update unmanaged object"
    Store.update Node.id(object), Node.some_fields(object, fields)
  
  # Remove objects from the scene
  remove: (object) ->
    unless Node.managed object
      throw new SG.Error "Tried to remove unmanaged object"
    Store.remove Node.id(object)
  
  # Register the new-object callback
  added: (callback) ->
    Store.set_added_callback @scene_id, callback
  


