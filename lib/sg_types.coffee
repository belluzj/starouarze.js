# Types of scene objects

T = SG.Types

SG.type 'Node', [],
  owner_id: T.String

SG.type 'Mesh', ['Node'],
  mesh:
    name: T.String
    position: T.Vector3
    material:
      diffuseColor: T.Color3

SG.type 'TestCube', ['Mesh'], {}

SG.type 'Laser', ['Mesh'], {}

