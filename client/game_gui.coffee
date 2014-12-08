
Template.GameLayout.rendered = ->
  $(window).on 'keydown', (event) ->
    console.log(event)
    switch event.which
      when KeyCodes.LEFT_ARROW
        BB.cube.mesh.position.x -= 20
      when KeyCodes.RIGHT_ARROW
        BB.cube.mesh.position.x += 20
      when KeyCodes.UP_ARROW
        BB.cube.mesh.position.y += 20
      when KeyCodes.DOWN_ARROW
        BB.cube.mesh.position.y -= 20
      when KeyCodes.SPACE
        BB.cube.mesh.material.diffuseColor.r = 1
    scenegraph.get().update BB.cube



  
  
