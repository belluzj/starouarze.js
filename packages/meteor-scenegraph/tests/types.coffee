Type = SG.Internals.Type

Tinytest.add 'meteor-scenegraph - Type.resolve()', (test) ->
  test.throws (-> Type.resolve()), 'arguments'
  test.throws (-> Type.resolve 'Bad'), 'unknown'
  test.throws (-> Type.resolve {field: 'Bad'}), 'unknown'
  test.throws (-> Type.resolve {foo: {bar: {baz: 'Bad'}}}), 'unknown'

  # Put the intermediary type checks
  type = Type.resolve {foo: {bar: {baz: Type.Types.String}}}
  test.isTrue _.isObject(type)
  test.equal type.__type_check, Object
  test.equal type.foo.__type_check, Object
  test.equal type.foo.bar.__type_check, Object
  test.equal type.foo.bar.baz, Type.Types.String

  test.equal Type.resolve(Type.Types.String), Type.Types.String
  test.equal Type.resolve(Type.Types.Integer), Type.Types.Integer
  test.equal Type.resolve(Type.Types.Number), Type.Types.Number
  test.equal Type.resolve(Type.Types.Boolean), Type.Types.Boolean


Tinytest.add 'meteor-scenegraph - Type.register()', (test) ->
  test.throws (-> Type.register()), "arguments"
  test.throws (-> Type.register 'Test'), "arguments"
  test.throws (-> Type.register 'Test', []), "arguments"
  test.throws (-> Type.register 'Test', [], {}), "empty definition"
  test.throws (-> Type.register '', [], {x: Type.Types.Integer}), "empty name"
  test.throws (-> Type.register 'Test', ['Bad'], {}), "unknown parent"

  Type.register 'Labeled', [], {label: Type.Types.String}
  test.isTrue _.isObject(Type.Types.Labeled)
  test.equal Type.Types.Labeled.__type_check, Object
  test.equal Type.Types.Labeled.label, Type.Types.String

  Type.register 'Rated', [], {rating: Type.Types.Number}
  test.isTrue _.isObject(Type.Types.Rated)
  test.equal Type.Types.Rated.__type_check, Object
  test.equal Type.Types.Rated.rating, Type.Types.Number

  Type.register 'Song', ['Labeled', Type.Types.Rated], {}
  test.isTrue _.isObject(Type.Types.Song)
  test.equal Type.Types.Song.__type_check, Object
  test.equal Type.Types.Song.label, Type.Types.String
  test.equal Type.Types.Song.rating, Type.Types.Number

  Type.register 'Artist', [],
    songs:
      best: 'Song'
  test.isTrue _.isObject(Type.Types.Artist)
  test.equal Type.Types.Artist.__type_check, Object
  test.isTrue _.isObject(Type.Types.Artist.songs)
  test.equal Type.Types.Artist.songs.__type_check, Object
  test.isTrue _.isObject(Type.Types.Artist.songs.best)
  test.equal Type.Types.Artist.songs.best.__type_check, Object
  test.equal Type.Types.Artist.songs.best.label, Type.Types.String
  test.equal Type.Types.Artist.songs.best.rating, Type.Types.Number

Tinytest.add 'meteor-scenegraph - Type.check_type_rec()', (test) ->
  vector2 =
    __type_check: Object
    x: Type.Types.Number
    y: Type.Types.Number

  Type.check_type_rec('', vector2, {x: 1, y: 1})
  Type.check_type_rec('', vector2, {x: 1, y: 1, other: "pouet"})
  
  test.throws (-> Type.check_type_rec('', vector2, {x: 1, y: {x: 1, y: 1}})), '.y'
  test.throws (-> Type.check_type_rec('', vector2, {x: 1, y: null})), '.y'
  test.throws (-> Type.check_type_rec('', vector2, {x: 1, y: undefined})), '.y'
  test.throws (-> Type.check_type_rec('', vector2, {x: 1, y: "1"})), '.y'
  test.throws (-> Type.check_type_rec('', vector2, {x: 1, z: 1})), '.y'

  nested =
    __type_check: Object
    x:
      __type_check: Object
      y:
        __type_check: Object
        z: Type.Types.Number

  Type.check_type_rec '', nested,
    c: 'hop'
    x:
      t: 'plof'
      y:
        r: 'plop'
        z: 1

  test.throws (-> Type.check_type_rec('', nested, {x: 1})), '.x'
  test.throws (-> Type.check_type_rec('', nested, {x: {}})), '.x.y'
  test.throws (-> Type.check_type_rec('', nested, {x: {y: 1}})), '.x.y'
  test.throws (-> Type.check_type_rec('', nested, {x: {y: {}}})), '.x.y.z'
  test.throws (-> Type.check_type_rec('', nested, {x: {y: {z: "pouet"}}})), '.x.y.z'

Tinytest.add 'meteor-scenegraph - Type.check_type()', (test) ->
  Type.check_type
    type: 'Vector2'
    x: 1
    y: 1
  Type.check_type
    type: 'Vector2'
    x: 1
    y: 1
    other: "plof"

  test.throws (-> Type.check_type 'pouet'), 'object'
  test.throws (->
    Type.check_type
      x: 1
      y: 1), 'type information'
  test.throws (->
    Type.check_type
      type: false
      x: 1
      y: 1), 'type information'
  test.throws (->
    Type.check_type
      type: "gloubiboulga"
      x: 1
      y: 1), 'unknown'
  test.throws (->
    Type.check_type
      type: 'Vector2'
      x: {}
      y: 1), 'Vector2.x'

Tinytest.add 'meteor-scenegraph - Type.get_type()', (test) ->
  test.equal Type.get_type(type: 'Vector2'), Type.Types.Vector2

  test.throws (-> Type.get_type 'pouet'), 'object'
  test.throws (-> Type.get_type {}), 'type information'
  test.throws (-> Type.get_type type: false), 'type information'
  test.throws (-> Type.get_type type: "gloubiboulga"), 'unknown'

Tinytest.add 'meteor-scenegraph - Type.some_fields_rec()', (test) ->
  nested =
    __type_check: Object
    x:
      __type_check: Object
      y1:
        __type_check: Object
        z: Type.Types.Number
      y2:
        __type_check: Object
        z: Type.Types.Number
  instance =
    c: 'hop'
    x:
      t: 'plof'
      y1:
        r: 'plop'
        z: 1
      y2:
        r: 'bof'
        z: 2

  test.equal Type.some_fields_rec(nested, instance, true),
    x:
      y1:
        z: 1
      y2:
        z: 2
  test.equal Type.some_fields_rec(nested, instance, x: true),
    x:
      y1:
        z: 1
      y2:
        z: 2
  test.equal Type.some_fields_rec(nested, instance, x: y1: true),
    x:
      y1:
        z: 1
  test.equal Type.some_fields_rec(nested, instance, x: y2: true),
    x:
      y2:
        z: 2

  # The updated fields specification must only contain true
  test.throws (-> Type.some_fields_rec(nested, instance, x: y2: "pouet")), "fields"

Tinytest.add 'meteor-scenegraph - Type.some_fields()', (test) ->


###

Type.some_fields_rec = (type, object, fields) ->
  subset = {}
  for own name, field_type of type when name != '__type_check'
    subfields = (fields == true) or fields[name]
    if subfields
      if _.isObject(object[name]) and field_type.__type_check == Object
        subset[name] = Type.some_fields_rec field_type, object[name], subfields
      else
        subset[name] = object[name]
  subset

Type.some_fields = (object, fields) ->
  ret = Type.some_fields_rec Type.get_type(object), object, fields
  ret.type = object.type
  ret

Type.all_fields = (object) ->
  Type.some_fields object, true

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



###
