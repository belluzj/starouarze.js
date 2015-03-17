class @TestCube extends Mesh
  type: 'TestCube'

  constructor: (babylonScene) ->
    @mesh = BB.Mesh.CreateBox 'cube', 10, babylonScene
    @mesh.material = new BB.StandardMaterial 'plaincolor', babylonScene
    @mesh.material.diffuseColor = new BB.Color3(0, 1, 0)

