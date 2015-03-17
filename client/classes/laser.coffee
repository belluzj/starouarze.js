class @Laser extends Mesh
    type: 'Laser'
 
    constructor: (position, rotation, @speed, @color) ->
        @length = 30
        @remainingFrames = 50
        @owner_id = Meteor.userId()
        
        #FIXME - length/2 on the other side and other cases 
        @mesh = BB.Mesh.CreateCylinder 'laser', @length, 1, 1, 6, 1, BB.scene
        @mesh.position.x = position.x
        @mesh.position.y = position.y
        @mesh.position.z = position.z + length/2
        @mesh.rotation.x = rotation.x + Math.atan(1)*2
        @mesh.rotation.y = rotation.y
        @mesh.rotation.z = rotation.z
        
        @mesh.material = new BB.StandardMaterial 'plaincolor', BB.scene
        @mesh.material.diffuseColor = new BB.Color3(0, 1, 0)
        
        #SG.Scene::add(@)
        @move()
        
    #FIXME update position according to actual dynamics 
    move: ->
      console.log('move')
      @mesh.position.z += @speed
      if(@remainingFrames-- > 0)
        setTimeout (@move.bind @), 20
      else
        @mesh.dispose()
        delete @
    