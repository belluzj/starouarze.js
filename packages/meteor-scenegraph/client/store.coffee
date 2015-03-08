Node = @Node

Store.subscribe = (scene_id) ->
  Store.collections[scene_id] = new Mongo.Collection 'scenegraph_' + scene_id
  Store.collections[scene_id].find().observeChanges
    added:   _.partial(Store.coll_added  , scene_id)
    changed: _.partial(Store.coll_changed, scene_id)
    removed: _.partial(Store.coll_removed, scene_id)
  Meteor.subscribe 'scenegraph', scene_id

# Start managing a fresh user-created object
Store.manage = (object) ->
  node_id = (new Mongo.ObjectID()).toHexString()
  Node.set_id object, node_id
  scene_id = Node.scene_id object
  unless _.isObject Store.objects[scene_id]
    Store.objects[scene_id] = {}
  Store.objects[scene_id][node_id] = object
  Meteor.call 'scenegraph_insert', scene_id, node_id, Node.all_fields object

# Update an object
Store.update = (scene_id, node_id, fields) ->
  # Nothing to do here, our local object is already up-to-date
  Meteor.call 'scenegraph_update', scene_id, node_id, fields

# Remove an object from the store
Store.remove = (scene_id, node_id) ->
  delete Store.objects[scene_id][node_id]
  Meteor.call 'scenegraph_remove', scene_id, node_id

# Internal methods
# ----------------

# Handle new object
Store.coll_added = (scene_id, node_id, fields) ->
  # console.log('Store.added', scene_id, node_id, fields)
  # FIXME fields already contains scene_id, node_id in __sg_data? If so, check that they're the same?
  object = Type.create fields
  Node.manage object, scene_id
  Node.set_id object, node_id
  Node.update object, fields
  unless _.isObject Store.objects[scene_id]
    Store.objects[scene_id] = {}
  Store.objects[scene_id][node_id] = object

# Dispatch object updates
Store.coll_changed = (scene_id, node_id, fields) ->
  # console.log('Store.changed', node_id, fields)
  object = Store.objects[scene_id]?[node_id]
  if object
    Node.update object, fields
  else
    throw new SG.Error "TODO"
    #   unless _.isArray Store.changed_queue[scene_id]
    #     Store.changed_queue[scene_id] = []
    #   Store.changed_queue[scene_id].push [node_id, fields]

# Handle object removals
Store.coll_removed = (scene_id, node_id) ->
  # console.log('Store.removed', node_id)
  object = Store.objects[scene_id]?[node_id]
  if object
    Node.remove object
    delete Store.objects[scene_id][node_id]
  else
    throw new SG.Error "TODO"
    # unless _.isArray Store.removed_queue[scene_id]
    #   Store.removed_queue[scene_id] = []
    # Store.removed_queue[scene_id].push [node_id]


# Data structures
# ---------------

# Minimongo collections
# scene_id -> collection
Store.collections = {}

# Managed objects
# scene_id -> { node_id -> user object }
Store.objects = {}

# Queued updates while we don't know the target object
# scene_id -> [queued updates]
#Store.changed_queue = {}

# Queued updates while we don't know the target object
# scene_id -> [queued removals]
#Store.removed_queue = {}

