Node = @Node

# The object store
@Store = Store = {}
Internals.Store = Store

# Public methods
# --------------
  
Store.publish = (callback) ->
  Meteor.publish 'scenegraph', (scene_id) ->
    if callback.call this, scene_id
      Store.collection.find scene_id: scene_id
    else
      @ready()

Store.subscribe = (scene_id) ->
  Meteor.subscribe 'scenegraph', scene_id

# Add an object to the store and send its node_id to the given callback
Store.insert = (object) ->
  document = Node.all_fields(object)
  console.log(document)
  Store.collection.insert Node.all_fields(object), (error, node_id) ->
    if error
      throw new SG.Error "Mongo insertion error " + error
    Store.objects[node_id] = object
    Node.set_id object, node_id

# Remove an object from the store
Store.remove = (node_id) ->
  Store.collection.remove node_id
  delete Store.objects[node_id]

# Update an object
Store.update = (node_id, fields) ->
  Store.collection.update node_id,
    $set: fields

# Set the function that can construct new user objects of a given type
Store.set_added_callback = (scene_id, callback) ->
  Store.added_callback[scene_id] = callback
  for params in Store.added_queue[scene_id] or []
    Store.added params

# Set the functions that determine whether a modification is OK
Store.allow = (callbacks) ->
  Store.collection.allow
    insert: callbacks.insert
    remove: callbacks.remove
    update: (userId, doc, fields, modifier) ->
      # Here the modifier should be of the form
      # {$set: {modified-fields}}
      callbacks.update(userId, doc, modifier.$set)

# Internal methods
# ----------------

# Handle new object
Store.added = (node_id, fields) ->
  console.log('Store.added', node_id, fields)
  scene_id = fields.scene_id
  if Store.added_callback[scene_id]
    object = Store.added_callback[scene_id](fields.type)
    if object
      Node.manage scene_id, object
      Node.set_id object, node_id
      Node.update object, fields
      Store.objects[node_id] = object
  else
    unless _.isArray Store.added_queue[scene_id]
      Store.added_queue[scene_id] = []
    Store.added_queue[scene_id].push [node_id, fields]

# Dispatch object updates
Store.changed = (node_id, fields) ->
  console.log('Store.changed', node_id, fields)
  object = Store.objects[node_id]
  if object
    Node.update object, fields
  else
    Store.changed_queue.push [node_id, fields]

# Handle object removals
Store.removed = (node_id) ->
  console.log('Store.removed', node_id)
  object = Store.objects[node_id]
  if object
    Node.remove object
    delete Store.objects[node_id]
  else
    Store.removed_queue.push [node_id]


# Data structures
# ---------------

# In-memory collection of objects, to be synchronized between players by Meteor
Store.collection = new Mongo.Collection 'scenegraph-nodes'

# node_id -> user object association
Store.objects = {}

# Callback for new objects, one per scene
Store.added_callback = {}

# Queued new objects while we don't have a callback, one queue per scene
Store.added_queue = {}

# Queued updates while we don't know the target object
Store.changed_queue = []

# Queued updates while we don't know the target object
Store.removed_queue = []


# Startup code
# ------------

# Watch the collection for changes
Store.collection.find().observeChanges
  added: Store.added
  changed: Store.changed
  removed: Store.removed

