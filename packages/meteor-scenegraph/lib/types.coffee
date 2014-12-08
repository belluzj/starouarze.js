SG = @SG

@Type = Type = {}

Type.register = (name, inheritance, type) ->
  type = Type.resolve type
  inheritance = _.map inheritance, Type.resolve
  # Mix in inherited fields
  complete_type = _.defaults.apply(_, [type].concat inheritance)
  Type.Types[name] = complete_type

Type.resolve = (type) ->
  if type?.__type_check
    type
  else if _.isString(type) and Type.Types[type]
    Type.Types[type]
  else if _.isObject type
    ret = {}
    for own name, field_type of type
      ret[name] = Type.resolve field_type
    ret.__type_check = Object
    ret
  else
    throw new SG.Error "Type `#{ type }' not found"

Type.check_type_rec = (path, type, object) ->
  for own name, field_type of type when name != '__type_check'
    subpath = path + '.' + name
    if _.isObject object[name]
      unless field_type.__type_check == Object
        throw new SG.Error "Field #{ subpath } of unexpected object type"
      Type.check_type_rec subpath, field_type, object[name]
    else
      unless Match.test object[name], field_type.__type_check
        throw new SG.Error "Field #{ subpath } does not match its type"

Type.get_type = (object) ->
  unless _.isObject(object) and _.isString(object.type)
    throw new SG.Error "Object #{ object } does not
      carry type information ('type' property should
      be the name of a registered type)"
  unless type = Type.Types[object.type]
    throw new SG.Error "Object #{ object } is of
      unknown type '#{ object.type }'"
  type

Type.check_type = (object) ->
  Type.check_type_rec object?.type, Type.get_type(object), object

Type.some_fields_rec = (type, object, fields) ->
  subset = {}
  for own name, field_type of type when name != '__type_check'
    if !fields or fields[name]
      if _.isObject(object[name]) and field_type.__type_check == Object
        subset[name] = Type.some_fields_rec field_type, object[name], fields?[name]
      else
        subset[name] = object[name]
  subset

Type.some_fields = (object, fields) ->
  ret = Type.some_fields_rec Type.get_type(object), object, fields
  ret.type = object.type
  ret

Type.all_fields = (object) ->
  Type.some_fields object, null

Type.update_rec = (type, object, fields) ->
  for own name, field_type of type when name != '__type_check'
    if fields[name]
      if _.isObject(object[name]) and field_type.__type_check == Object
        Type.update_rec field_type, object[name], fields[name]
      else
        # TODO maybe type checks here?
        object[name] = fields[name]

Type.update = (object, fields) ->
  Type.update_rec Type.get_type(object), object, fields


Type.Types = {}

Type.Types.Optional = (type) ->
  type = Type.resolve type
  __type_check: Match.Optional type.__type_check

Type.Types.Integer =
  __type_check: Match.Integer

Type.Types.Number =
  __type_check: Number

Type.Types.String =
  __type_check: String

Type.Types.Boolean =
  __type_check: Boolean

Type.Types.Enum = (values) ->
  __type_check: Match.Where (x) ->
    x in values

Type.register 'Vector2', [],
  x: Type.Types.Number
  y: Type.Types.Number

Type.register 'Vector3', ['Vector2'],
  z: Type.Types.Number

Type.register 'Quaternion', ['Vector3'],
  w: Type.Types.Number

Type.register 'Color3', [],
  r: Type.Types.Number
  g: Type.Types.Number
  b: Type.Types.Number
  
Type.register 'Color4', ['Color3'],
  a: Type.Types.Number



