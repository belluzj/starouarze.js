@Node = Node = {}
@Internals.Node = Node

# Public methods
# --------------

# Add our secret properties to a user object
Node.manage = (scene_id, object) ->
  Type.check_type object
  object.__sg_data =
    scene_id: scene_id

Node.managed = (object) ->
  object?.hasOwnProperty '__sg_data'

Node.set_id = (object, node_id) ->
  object.__sg_data.node_id = node_id
  # TODO flush changed in the store?

Node.id = (object) ->
  object?.__sg_data?.node_id

Node.all_fields = (object) ->
  ret = Node.some_fields object, null
  if object.__sg_data.node_id
    ret._id = object.__sg_data.node_id
  ret

Node.some_fields = (object, fields) ->
  ret = Type.some_fields object, fields
  ret.scene_id = object.__sg_data.scene_id
  ret

Node.update = (object, fields) ->
  console.log(object, fields)
  if _.isFunction object.sg_before_update
    object.sg_before_update fields
  else
    Type.update object, fields
  if _.isFunction object.sg_after_update
    object.sg_after_update fields

Node.remove = (object) ->
  if _.isFunction object.sg_before_remove
    object.sg_before_remove()

