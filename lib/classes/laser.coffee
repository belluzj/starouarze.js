class @Laser extends Mesh
  type: 'Laser'
 
  # Always take the babylon scene as an argument because on the server we have several scenes (one per round being played)
  constructor: (babylonScene) ->
    @speed = 40
    @length = 30
    @remainingFrames = 50
    @owner_id = Meteor.userId()
    
    #FIXME - length/2 on the other side and other cases 
    @mesh = BB.Mesh.CreateCylinder 'laser', @length, 1, 1, 6, 1, babylonScene
    @mesh.material = new BB.StandardMaterial 'plaincolor', babylonScene
    @mesh.material.diffuseColor = new BB.Color3(0, 1, 0)
    
    # FIXME instead of having one timer per object, add a step() function that will be called by the scenegraph
    # TODO jany add a step function to the scenegraph
    # TODO jany add mouvement classes with tweening
    # TODO jany add time synchronization to scenegraph
    @move()
    
  setPosRot: (position, rotation) ->
    @mesh.position.x = position.x
    @mesh.position.y = position.y
    @mesh.position.z = position.z + length/2
    @mesh.rotation.x = rotation.x + Math.atan(1)*2
    @mesh.rotation.y = rotation.y
    @mesh.rotation.z = rotation.z
    
  #FIXME update position according to actual dynamics 
  move: ->
    console.log('move')
    @mesh.position.z += @speed
    if(@remainingFrames-- > 0)
      setTimeout (@move.bind @), 20
    else
      @mesh.dispose()
      delete @
  
