class @TestCube extends Mesh
  type: 'TestCube'

  constructor: () ->
    @mesh = BB.Mesh.CreateBox 'cube', 10, BB.scene
    @mesh.material = new BB.StandardMaterial 'plaincolor', BB.scene
    @mesh.material.diffuseColor = new BB.Color3(0, 1, 0)

