SG = @SG

@Type = Type = {}
Internals.Type = Type

# First part: type definition, verification

Type.register = (name, inheritance, type) ->
  try
    check name, String
    check inheritance, [Match.OneOf String, Object]
    check type, Match.OneOf String, Object
  catch error
    throw new SG.Error "Type.register: invalid arguments", error
  if name == ''
    throw new SG.Error "Type.register: new type has an empty name"
  # Resolve field types
  try
    type = Type.resolve type
  catch error
    throw new SG.Error "Type.register: unknown field type #{ type }", error
  # Resolve parent types
  inheritance = _.map inheritance, (type) ->
    try
      Type.resolve type
    catch error
      throw new SG.Error "Type.register: unknown parent type #{ type }", error
  # Mix in inherited fields
  complete_type = _.defaults.apply(_, [type].concat inheritance)
  empty = true
  for own field of complete_type
    if field != '__type_check'
      empty = false
  if empty
    throw new SG.Error "Type.register: new type `#{ name }` has an empty definition"
  Type.Types[name] = complete_type

Type.resolve = (type) ->
  try
    check type, Match.OneOf String, Object
  catch error
    throw new SG.Error "Type.resolve: invalid arguments", error
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
    throw new SG.Error "Type.resolve: unknown type `#{ type }'"

Type.check_type_rec = (path, type, object) ->
  for own name, field_type of type when name != '__type_check'
    subpath = path + '.' + name
    if _.isObject object[name]
      unless field_type.__type_check == Object
        throw new SG.Error "Type.check_type_rec: field #{ subpath } of unexpected object type"
      Type.check_type_rec subpath, field_type, object[name]
    else
      unless Match.test object[name], field_type.__type_check
        throw new SG.Error "Type.check_type_rec: field #{ subpath } does not match its type"

Type.get_type = (object) ->
  unless _.isObject(object)
    throw new SG.Error "Type.get_type: not an object"
  unless _.isString(object.type)
    throw new SG.Error "Type.get_type: object does not
      carry type information ('type' property should
      be the name of a registered type)"
  unless Type.Types.hasOwnProperty(object.type)
    throw new SG.Error "Type.get_type: object is of
      unknown type '#{ object.type }'"
  Type.Types[object.type]

Type.check_type = (object) ->
  Type.check_type_rec object?.type, Type.get_type(object), object


#
# Second part: extraction (some/all_fields), reinsertion (update)
#
# When we extract `undefined` we transform into `Type.undefined_field`,
# inversely when we update an object we transform `Type.undefined_field`
# into a *missing property*, as opposed to a property set to `undefined`.
#
# Users should never see Type.undefined_field
#
Type.some_fields_rec = (type, object, fields) ->
  subset = {}
  for own name, field_type of type when name != '__type_check'
    unless (fields == true) or (
      _.isObject(fields) and (
        !fields.hasOwnProperty(name) or
        _.isObject(fields[name]) or
        fields[name] == true))
          throw new SG.Error "Type.some_fieds_rec: wrong specifier of updated fields"
    subfields = (fields == true) or fields[name]
    if _.isObject(object[name]) and field_type.__type_check == Object
      if subfields == true or _.isObject(subfields)
        subset[name] = Type.some_fields_rec field_type, object[name], subfields
    else
      if _.isObject(subfields)
        throw new SG.Error "Type.some_fieds_rec: wrong specifier of updated fields"
      if subfields == true
        subset[name] =
          if object[name] == undefined
            Type.undefined_field
          else
            object[name]
  subset

Type.some_fields = (object, fields) ->
  ret = Type.some_fields_rec Type.get_type(object), object, fields
  ret.type = object.type
  ret

Type.all_fields = (object) ->
  Type.some_fields object, true

Type.update_rec = (path, type, object, fields) ->
  for own name, field_type of type when name != '__type_check'
    subpath = path + '.' + name
    if fields.hasOwnProperty(name)
      unless Match.test(fields[name], field_type.__type_check) or
          (fields[name] == Type.undefined_field and
            Match.test(undefined, field_type.__type_check))
        throw new SG.Error "Type.update_rec: field #{ subpath } does not match its type"
      if field_type.__type_check == Object
        Type.update_rec subpath, field_type, object[name], fields[name]
      else
        if fields[name] != Type.undefined_field
          object[name] = fields[name]
        else
          delete object[name]

Type.update = (object, fields) ->
  Type.update_rec "", Type.get_type(object), object, fields

Type.factory = (type, factory) ->
  try
    check type, Match.OneOf String, Object
    check factory, Function
  catch error
    throw new SG.Error "Type.factory: invalid arguments", error
  type = Type.resolve type
  type.__factory = factory

Type.create = (fields) ->
  try
    check fields, Object
  catch error
    throw new SG.Error "Type.create: invalid argument", error
  type = Type.get_type(fields)
  if type.hasOwnProperty('__factory')
    fields_ = {type: fields.type}
    Type.update(fields_, fields)
    Type.check_type(fields_)
    type.__factory(fields_)
  else
    {}

# Make undefined fields JSON-able
Type.undefined_field =
  typeName: ->
    "sg_undefined_field"
  toJSONValue: ->
    ""
EJSON.addType Type.undefined_field.typeName(), ->
  Type.undefined_field

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



