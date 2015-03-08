Node = @Node

# Public methods
# --------------
  
Store.publish = (callback) ->
  Meteor.publish 'scenegraph', (scene_id) ->
    # Check parameters
    # TODO
    if callback.call this, scene_id
      # Publish the whole scene as it is now
      for own node_id, obj of Store.nodes[scene_id]
        @added('scenegraph_' + scene_id, node_id, Node.all_fields(obj))
      # Send other changes later
      unless Store.users[scene_id]
        Store.users[scene_id] = {}
      Store.users[scene_id][@userId] = this
      # Handle end of subscription
      user_id = @userId
      @onStop ->
        delete Store.users[scene_id][user_id]
    @ready()

Store.method_insert = (scene_id, node_id, fields) ->
  check scene_id, String
  check node_id, String
  check fields, Object
  # TODO if allow...
  # if allowed, send to everyone except the caller
  # else, send back to the caller a roll-back
  unless _.isObject Store.nodes[scene_id]
    Store.nodes[scene_id] = {}
  Store.nodes[scene_id][node_id] = fields
  for own user_id, handle of Store.users[scene_id]
    if user_id != @userId
      handle.added('scenegraph_' + scene_id, node_id, fields)

Store.method_update = (scene_id, node_id, fields) ->
  check scene_id, String
  check node_id, String
  check fields, Object
  # TODO if allow...
  # if allowed, send to everyone except the caller
  # else, send back to the caller a roll-back
  # TODO
  #Node.update Store.nodes[scene_id][node_id], fields
  for own user_id, handle of Store.users[scene_id]
    if user_id != @userId
      handle.changed('scenegraph_' + scene_id, node_id, fields)

Store.method_remove = (scene_id, node_id) ->
  check scene_id, String
  check node_id, String
  # TODO if allow...
  # if allowed, send to everyone except the caller
  # else, send back to the caller a roll-back
  # TODO
  #delete Store.nodes[scene_id][node_id]
  for own user_id, handle of Store.users[scene_id]
    if user_id != @userId
      handle.removed('scenegraph_' + scene_id, node_id)

# Data structures
# ---------------

# Subscribed users with associated publish handle
# scene_id -> { user_id -> publish handle }
Store.users = {}

# Managed nodes (only sync. fields, not whole user objects)
# scene_id -> { node_id -> synchronized node fields }
Store.nodes = {}

# Startup code
# ------------

# Register the server-side methods for scene updates
Meteor.methods
  scenegraph_insert: Store.method_insert
  scenegraph_update: Store.method_update
  scenegraph_remove: Store.method_remove

