
# Create a BABYLON engine for the canvas and put it in
# the global reactive variable BB.engine

Template.babylonCanvas.rendered = ->
  # Get the canvas element
  canvas = @$('#renderCanvas')[0]
  # Load the BABYLON 3D engine
  BB.engine = new BB.Engine(canvas, true)
  # Watch for browser/canvas resize events
  window.addEventListener 'resize', ->
    BB.engine.resize()
