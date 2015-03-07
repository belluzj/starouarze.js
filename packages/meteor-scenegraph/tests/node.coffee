Node = SG.Internals.Node

Tinytest.add 'meteor-scenegraph - Node - manage()', (test) ->
  test.throws (-> Node.manage()), 'arguments'
  test.throws (-> Node.manage 45), 'arguments'
  test.throws (-> Node.manage {}), 'arguments'
  test.throws (-> Node.manage {no: 'type'}, 'some scene id'), 'arguments'
  test.throws (-> Node.manage {type: 'undefined type'}, 'some scene id'), 'arguments'
  test.throws (-> Node.manage({
    type: 'Vector2'
    not: 'the right fields'
  }, 'some scene id')), 'arguments'

  object =
    type: 'Vector2'
    x: 4012
    y: 5

  Node.manage object, 'some scene id'
  test.isTrue object.hasOwnProperty '__sg_data'
  test.equal object.__sg_data.scene_id, 'some scene id'

Tinytest.add 'meteor-scenegraph - Node - managed()', (test) ->
  test.isFalse Node.managed null
  test.isFalse Node.managed undefined
  test.isFalse Node.managed 45
  test.isFalse Node.managed ""
  test.isFalse Node.managed {}
  test.isFalse Node.managed {__sg_data: 45}
  test.isFalse Node.managed {__sg_data: {}}
  
  test.isTrue Node.managed {__sg_data: {scene_id: "test"}}

Tinytest.add 'meteor-scenegraph - Node - set_id()', (test) ->
  test.throws (-> Node.set_id()), 'arguments'
  test.throws (-> Node.set_id 45), 'arguments'
  test.throws (-> Node.set_id {}, 45), 'arguments'
  test.throws (-> Node.set_id {}, ''), 'arguments'
  test.throws (-> Node.set_id {}, 'some id'), 'managed'
  test.throws (-> Node.set_id {__sg_data: {scene_id: 42}}, 'some id'), 'managed'

  object = {__sg_data: {scene_id: "test"}}

  Node.set_id object, 'some id'

  test.equal object.__sg_data.node_id, 'some id'

Tinytest.add 'meteor-scenegraph - Node - id()', (test) ->
  test.throws (-> Node.id()), 'argument'
  test.throws (-> Node.id 45), 'argument'
  test.throws (-> Node.id {}), 'managed'

  test.equal Node.id(__sg_data: {scene_id: 'test'}), undefined
  test.equal Node.id(__sg_data: {scene_id: 'test', node_id: 'toto'}), 'toto'

Tinytest.add 'meteor-scenegraph - Node - scene_id()', (test) ->
  test.throws (-> Node.scene_id()), 'argument'
  test.throws (-> Node.scene_id 45), 'argument'
  test.throws (-> Node.scene_id {}), 'managed'
  test.throws (-> Node.scene_id __sg_data: {}), 'managed'

  test.equal Node.scene_id(__sg_data: {scene_id: 'toto'}), 'toto'

Tinytest.add 'meteor-scenegraph - Node - all_fields()', (test) ->
  test.throws (-> Node.all_fields()), 'argument'
  test.throws (-> Node.all_fields 45), 'argument'
  test.throws (-> Node.all_fields {})
  test.throws (-> Node.all_fields {type: 'Vector2', x: 1, y: 2}), 'managed'
  test.throws (-> Node.all_fields {
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
    type: 'undefined type'
  }), 'type'
  test.throws (-> Node.all_fields {
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
    type: 'Vector2'
  }), 'type'
  test.throws (-> Node.all_fields
    type: 'Vector2'
    x: 1
    y: 2
    __sg_data:
      scene_id: 'some scene id'
  ), 'node id'
  test.throws (-> Node.all_fields
    type: 'Vector2'
    x: 1
    y: "pouet"
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  ), 'Vector2.y'

  test.equal Node.all_fields(
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 1
    y: 2
    x2: 45
    custom: 'fields'
  ),
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
    type: 'Vector2'
    x: 1
    y: 2

Tinytest.add 'meteor-scenegraph - Node - some_fields()', (test) ->
  test.throws (-> Node.some_fields()), 'arguments'
  test.throws (-> Node.some_fields 45), 'arguments'
  test.throws (-> Node.some_fields {}), 'arguments'
  test.throws (-> Node.some_fields {}, 67), 'arguments'
  test.throws (-> Node.some_fields 45, true), 'arguments'
  test.throws (-> Node.some_fields 45, {x: true}), 'arguments'
  test.throws (-> Node.some_fields {
    type: 'undefined type'
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, true), 'type'
  test.throws (-> Node.some_fields {
    type: 'Vector2'
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, true)
  test.throws (-> Node.some_fields {
    type: 'Vector2'
    x: 1
    y: 2
  }, true), 'managed'
  test.throws (-> Node.some_fields {
    type: 'Vector2'
    x: 1
    y: 2
    __sg_data:
      scene_id: 'some scene id'
  }, true), 'node id'
  test.throws (-> Node.some_fields {
    type: 'Vector2'
    x: 1
    y: "pouet"
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, true), 'Vector2.y'
  test.throws (-> Node.some_fields {
    type: 'Vector2'
    x: 1
    y: 2
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, {
    x: {} # Should only contain `true`
  }), 'fields'

  test.equal Node.some_fields({
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 1
    y: 2
    x2: 45
    other: 'fields'
  }, {
    x: true
    other: true
  }),
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
    type: 'Vector2'
    x: 1

Tinytest.add 'meteor-scenegraph - Node - update()', (test) ->
  test.throws (-> Node.update()), 'arguments'
  test.throws (-> Node.update 45, {}), 'arguments'
  test.throws (-> Node.update {}, null), 'arguments'
  test.throws (-> Node.update {}, 23), 'arguments'
  test.throws (-> Node.update {}, {})
  test.throws (-> Node.update {
    type: 'undefined type'
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, {}), 'type'
  test.throws (-> Node.update {type: 'Vector2', x: 1, y: 2}, {}), 'managed'
  test.throws (-> Node.update {
    type: 'Vector2'
    x: 1
    y: 2
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
  }, {
    x: "pouet"
  }), '.x'
  # test.throws (-> Node.update {
  #   type: 'Vector2'
  #   x: 1
  #   y: 2
  #   __sg_data:
  #     scene_id: 'some scene id'
  #     node_id: 'some node id'
  # }, {
  #   x: 3
  #   y: 4
  #   other: 'not authorized' # Other fields are just ignored for now
  # }), 'fields'
  
  object =
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 1
    y: 2
    x2: 45
    other: 'fields'

  Node.update object, {}
  test.equal object, # no change
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 1
    y: 2
    x2: 45
    other: 'fields'
  
  Node.update object,
    x: 34
  test.equal object,
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 34
    y: 2
    x2: 45
    other: 'fields'

  object.sg_after_update = sinon.spy()
  Node.update object,
    x: 54
  test.isTrue object.sg_after_update.calledOnce
  test.isTrue object.sg_after_update.calledOn object
  test.isTrue object.sg_after_update.calledWithExactly x: 54
  delete object.sg_after_update
  test.equal object,
    __sg_data:
      scene_id: 'some scene id'
      node_id: 'some node id'
      other_stuff: "pouet"
    type: 'Vector2'
    x: 54
    y: 2
    x2: 45
    other: 'fields'

Tinytest.add 'meteor-scenegraph - Node - remove()', (test) ->
  test.throws (-> Node.remove()), 'argument'
  test.throws (-> Node.remove false), 'argument'
  test.throws (-> Node.remove {}), 'managed'

  object =
    __sg_data:
      scene_id: 'some scene id'
      blah: true
  Node.remove(object) # Does nothing
  test.equal object,
    __sg_data:
      scene_id: 'some scene id'
      blah: true

  object.sg_before_remove = sinon.spy()
  
  Node.remove(object) # Calls the callback
  test.isTrue object.sg_before_remove.calledOnce
  test.isTrue object.sg_before_remove.calledOn object
  test.isTrue object.sg_before_remove.calledWithExactly()
  delete object.sg_before_remove
  test.equal object,
    __sg_data:
      scene_id: 'some scene id'
      blah: true
