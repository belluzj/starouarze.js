# Enable scenegraph synchronization

@scenegraph = scenegraph = new ReactiveVar null

Tracker.autorun ->
  if Meteor.user() and Meteor.user().round_id
    scene = new SG.Scene Meteor.user().round_id
    scene.added (type) ->
      if type == 'TestCube'
        new TestCube()
    scene.subscribe()
    scenegraph.set(scene)

# Create the game scene
createGameScene = (engine) ->
  scene = new BB.Scene(engine)
  scene.clearColor = new BB.Color3(0, 0, 0)
  
  # TODO store this somewhere and make it follow the player
  camera = new BB.FreeCamera("camera1", new BB.Vector3(0, 50, -100), scene)
  camera.setTarget(BB.Vector3.Zero())
  
  # TODO create a point light for the sun and a bit of ambient light
  light = new BB.HemisphericLight("light1", new BB.Vector3(0, 1, 0), scene)

  scene

Tracker.autorun ->
  if BB.engine and Session.get('inGame')
    BB.scene = createGameScene(BB.engine)
    BB.engine.runRenderLoop ->
      BB.scene.render()

# Test objects
Tracker.autorun ->
    if BB.scene and scenegraph.get()
      BB.cube = new TestCube()
      BB.cube.owner_id = Meteor.userId()
      scenegraph.get().add BB.cube
