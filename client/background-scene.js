/*
 * Fill the UI background with an animated scene.
 */

// -------------------------------------------------------------
// Here begins a function that we will 'call' just after it's built
var createScene = function(engine) {

  // Now create a basic Babylon Scene object
  var scene = new BB.Scene(engine);

  // Change the scene background color to black.
  scene.clearColor = new BB.Color3(0, 0, 0);

  // This creates and positions a free camera
  var camera = new BB.FreeCamera("camera1", new BB.Vector3(0, 50, -100), scene);

  // This targets the camera to scene origin
  camera.setTarget(BB.Vector3.Zero());

  // This creates a light, aiming 0,1,0 - to the sky.
  var light = new BB.HemisphericLight("light1", new BB.Vector3(0, 1, 0), scene);

  // Dim the light a small amount
  light.intensity = .5;

  //Boxe
  var box1 = BB.Mesh.CreateBox("Box1", 10.0, scene);
  var materialBox = new BB.StandardMaterial("texture1", scene);
  materialBox.diffuseColor = new BB.Color3(0, 1, 0);
  //Green
  box1.position.x = -20;

  //Applying material
  box1.material = materialBox;
  var animationBox = new BB.Animation("tutoAnimation", "scaling.x", 30, BB.Animation.ANIMATIONTYPE_FLOAT, BB.Animation.ANIMATIONLOOPMODE_CYCLE);

  // Animation keys
  var keys = [];
  //At the animation key 0, the value of scaling is "1"
  keys.push({
    frame : 0,
    value : 1
  });

  //At the animation key 20, the value of scaling is "0.2"
  keys.push({
    frame : 20,
    value : 0.2
  });

  //At the animation key 100, the value of scaling is "1"
  keys.push({
    frame : 100,
    value : 1
  });

  //Adding keys to the animation object
  animationBox.setKeys(keys);

  //Then add the animation object to box1
  box1.animations.push(animationBox);

  //Finally, launch animations on box1, from key 0 to key 100 with loop activated
  scene.beginAnimation(box1, 0, 100, true);

  // Leave this function
  return scene;

};
// End of createScene function
// -------------------------------------------------------------

Tracker.autorun(function() {
  if (BB.engine && !Session.get('inGame')) {

    // Now, call the createScene function that you just finished creating
    var scene = createScene(BB.engine);

    // Register a render loop to repeatedly render the scene
    BB.engine.runRenderLoop(function() {
      scene.render();
    });
  }
});
