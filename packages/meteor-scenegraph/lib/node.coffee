@Node = Node = {}
@Internals.Node = Node

# Public methods
# --------------

# Add our secret properties to a user object
# The object must define its type and have all the required fields
Node.manage = (object, scene_id) ->
  try
    Type.check_type object
    check scene_id, String
  catch error
    throw new SG.Error "Node.manage: invalid arguments", error
  object.__sg_data =
    scene_id: scene_id

Node.managed = (object) ->
  (object?.hasOwnProperty('__sg_data') and
    _.isObject(object.__sg_data) and
    _.isString(object.__sg_data.scene_id))

Node.scene_id = (object) ->
  unless _.isObject(object)
    throw new SG.Error "Node.scene_id: invalid argument"
  unless Node.managed(object)
    throw new SG.Error "Node.scene_id: unmanaged object"
  object.__sg_data.scene_id

Node.set_id = (object, node_id) ->
  unless _.isObject(object) and _.isString(node_id) and node_id != ""
    throw new SG.Error "Node.set_id: invalid arguments"
  unless Node.managed(object)
    throw new SG.Error "Node.set_id: unmanaged object"
  object.__sg_data.node_id = node_id

Node.id = (object) ->
  unless _.isObject(object)
    throw new SG.Error "Node.id: invalid argument"
  unless Node.managed(object)
    throw new SG.Error "Node.id: unmanaged object"
  object.__sg_data.node_id

Node.all_fields = (object) ->
  Node.some_fields object, true

Node.some_fields = (object, fields) ->
  unless _.isObject(object) and (_.isObject(fields) or fields == true)
    throw new SG.Error "Node.some_fields: invalid arguments"
  unless Node.managed(object)
    throw new SG.Error "Node.some_fields: unmanaged object"
  unless _.isString(Node.id(object)) and Node.id(object) != ''
    throw new SG.Error "Node.some_fields: no node id"
  Type.check_type object
  ret = Type.some_fields object, fields
  ret.__sg_data =
    scene_id: object.__sg_data.scene_id
    node_id: object.__sg_data.node_id
  ret

Node.update = (object, fields) ->
  unless _.isObject(object) and _.isObject(fields)
    throw new SG.Error "Node.update: invalid arguments"
  unless Node.managed(object)
    throw new SG.Error "Node.update: unmanaged object"
  # NOTE if we implement sg_before_upadte, we have to do a check
  # on the fields object without touching the object.
  # if _.isFunction object.sg_before_update
  #   object.sg_before_update fields
  # else
  Type.update object, fields
  if _.isFunction object.sg_after_update
    object.sg_after_update fields

Node.remove = (object) ->
  unless _.isObject(object)
    throw new SG.Error "Node.remove: invalid arguments"
  unless Node.managed(object)
    throw new SG.Error "Node.remove: unmanaged object"
  if _.isFunction object.sg_before_remove
    object.sg_before_remove()

