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
      y3:
        __type_check: Match.Optional Number
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
      y3: Type.undefined_field
  test.equal Type.some_fields_rec(nested, instance, x: true),
    x:
      y1:
        z: 1
      y2:
        z: 2
      y3: Type.undefined_field
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
  # Throws for the same reasons as Type.get_type and Type.some_fields_rec
  test.throws (-> Type.some_fields({}, true)), ""

  Type.register 'Labeled', [], {label: Type.Types.String}
  Type.register 'Rated', [], {rating: Type.Types.Number}
  Type.register 'Song', ['Labeled', Type.Types.Rated], {}
  Type.register 'Artist', [],
    songs:
      best: 'Song'

  artist =
    type: 'Artist'
    name: 'Roberto'
    songs:
      worst:
        blop: 'pouet'
      best:
        label: 'Parlophone'
        rating: 2

  test.equal Type.some_fields(artist, true),
    type: 'Artist'
    songs:
      best:
        label: 'Parlophone'
        rating: 2

  test.equal Type.some_fields(artist, songs: best: label: true),
    type: 'Artist'
    songs:
      best:
        label: 'Parlophone'

Tinytest.add 'meteor-scenegraph - Type.all_fields()', (test) ->
  # Should just call Type.some_fields(..., true)
  # FIXME Not tested

Tinytest.add 'meteor-scenegraph - Type.update_rec()', (test) ->
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
      y3:
        __type_check: Match.Optional Number
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
      y3: 99

  # Correctly update an existing field
  Type.update_rec "", nested, instance, x: y1: z: 42
  test.equal instance,
    c: 'hop'
    x:
      t: 'plof'
      y1:
        r: 'plop'
        z: 42
      y2:
        r: 'bof'
        z: 2
      y3: 99

  # Ignore an unexisting field
  Type.update_rec "", nested, instance, x: y2: r: 'DO NOT DO THAT'
  test.equal instance,
    c: 'hop'
    x:
      t: 'plof'
      y1:
        r: 'plop'
        z: 42
      y2:
        r: 'bof'
        z: 2
      y3: 99

  # Ignore empty object (merge its new properties as usual = do nothing)
  Type.update_rec "", nested, instance, x: y1: {}
  test.equal instance,
    c: 'hop'
    x:
      t: 'plof'
      y1:
        r: 'plop'
        z: 42
      y2:
        r: 'bof'
        z: 2
      y3: 99

  # Correctly delete an optional field
  Type.update_rec "", nested, instance, x: y3: Type.undefined_field
  test.equal instance,
    c: 'hop'
    x:
      t: 'plof'
      y1:
        r: 'plop'
        z: 42
      y2:
        r: 'bof'
        z: 2
  
  # Throw if incompatible type
  test.throws (-> Type.update_rec("", nested, instance, x: y2: z: 'Not a number')), ".x.y2.z"
  test.throws (-> Type.update_rec("", nested, instance, x: y1: z: [])), ".x.y1.z"
  test.throws (-> Type.update_rec("", nested, instance, x: y1: 12345)), ".x.y1"


Tinytest.add 'meteor-scenegraph - Type.update()', (test) ->
  test.throws (-> Type.update({}, {})), ""

  Type.register 'Labeled', [], {label: Type.Types.String}
  Type.register 'Rated', [], {rating: Type.Types.Number}
  Type.register 'Song', ['Labeled', Type.Types.Rated], {}
  Type.register 'Artist', [],
    songs:
      best: 'Song'

  artist =
    type: 'Artist'
    name: 'Roberto'
    songs:
      worst:
        blop: 'pouet'
      best:
        label: 'Parlophone'
        rating: 2

  Type.update artist,
    songs:
      best:
        label: 'EMI'
  test.equal artist,
    type: 'Artist'
    name: 'Roberto'
    songs:
      worst:
        blop: 'pouet'
      best:
        label: 'EMI'
        rating: 2

  # Ignores undefined fields
  Type.update artist, name: 'Alonzo'
  test.equal artist,
    type: 'Artist'
    name: 'Roberto'
    songs:
      worst:
        blop: 'pouet'
      best:
        label: 'EMI'
        rating: 2

Tinytest.add 'meteor-scenegraph - Type.factory()', (test) ->
  test.throws (-> Type.factory()), "argument"
  test.throws (-> Type.factory('Vector2')), "argument"
  test.throws (-> Type.factory('Vector2', 45)), "argument"
  test.throws (-> Type.factory('Undefined Type', (->))), "unknown"

  Type.register 'Bird', [],
    distance: 'Number'

  fun = -> {}

  Type.factory 'Bird', fun

  test.equal Type.Types.Bird.__factory, fun

Tinytest.add 'meteor-scenegraph - Type.create()', (test) ->
  class DetailedBird
    type: 'Bird'
    mesh: 'bird.obj'

  class LowResBird
    type: 'Bird'
    mesh: 'cube.obj'

  Type.register 'Bird', [],
    distance: 'Number'
    color: Type.Types.Optional('String')

  Type.Types.Bird.__factory = (b) ->
    test.isFalse b.hasOwnProperty('color')
    test.equal b.distance, 42
    if b.distance > 20
      new LowResBird()
    else
      new DetailedBird()

  test.throws (-> Type.create()), "argument"
  test.throws (-> Type.create {}), "type"
  test.throws (-> Type.create type: 'Bird'), ".distance"

  b1 = Type.create
    type: 'Bird'
    distance: 42
    color: Type.undefined_field

  test.isTrue b1 instanceof LowResBird
  test.equal b1.type, 'Bird'
  test.equal b1.mesh, 'cube.obj'
  test.equal b1.distance, undefined # This function does not do the update



# TODO tests for pre-registered types?
