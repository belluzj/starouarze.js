
# We instantiate our graphical classes only on the client
# FIXME maybe also on the server to do collision detection?
# TODO make base classes only with collision detection capabilities and their extensions that also provide graphical aspects

SG.factory 'TestCube', (fields) ->
  new TestCube(BB.scene)

SG.factory 'Laser', (fields) ->
  new Laser(BB.scene)

