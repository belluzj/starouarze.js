class Laser
    constructor: (@position, @rotation, @speed, @color) ->
        @mesh = BB.Mesh.CreateCylinder(30, 3, 3, 6, 1, BB.scene)
        @mesh.position = @position
        @mesh.rotation = @rotation


Laser = (position, rotation, speed, color) ->
    position: position
    rotation: rotation
    color: color
    speed: speed
    mesh: BB.Mesh.CreateCylinder(30, 3, 3, 6, 1, BB.scene)
