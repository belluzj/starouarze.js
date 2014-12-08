class @Node
  owner_id: ''

  constructor: ->

class @Mesh extends Node
  mesh: null

  constructor: ->

  sg_before_remove: ->
    if @mesh
      @mesh.dispose()
      @mesh = null


