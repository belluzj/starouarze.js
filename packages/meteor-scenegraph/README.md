A reactive game scene graph
===========================

The scene graph is a collections of objects that are part of the same game
environment. This package makes it easy to synchronize the contents and state
of such an environment between multiple players and a server, in order to make
a multiplayer game.

How-to
------

### Share a scenegraph

A scene graph is only defined by its id. You should provide it.

In order to synchronize the scene between everyone, `SG.publish` and
`SG.Scene::subscribe` implement the same concept as `Meteor.publish` and
`Meteor.subscribe`. **These methods should be called only after you have
defined all the types and object factories (see below).**

```javascript
// On the server
SG.publish(function(scene_id) {
  // Check if the current user can access the given scene
  // You can only publish a whole scene, not part of it
  if (this.userId && ... ) {
    return true;
  }
  return false;
});

// Client
var scene = new SG.Scene(Meteor.user().my_scene_id);
scene.subscribe();
```

### Set up a scene graph

An object that is managed by the scene graph must have at least the following
fields:
* `type` (string): the type of this object

The type information is very important, because that's how the synchronization
mechanism knows which fields to synchronize. You must therefore specify for
each type a list of meaningful fields that should be taken care of:

```javascript
// On both sides

SG.type('Mat22', [], {
  a: SG.Types.Number,
  b: SG.Types.Number,
  c: SG.Types.Number,
  d: SG.Types.Number,
});

SG.type('Mesh', [], {
  position: SG.Types.Vector3,
  rotation: SG.Types.Optional(SG.Types.Quaternion),
})

SG.type('Noisy', [], {
  sound_file: SG.Types.String,
});

SG.type('Ship', ['Noisy'], {
  class: SG.Types.Enum(['destroyer', 'fighter']),
  mesh: 'Mesh',
});

SG.type('Laser', ['Noisy'], {
  start_pos: SG.Types.Vector3,
  direction: SG.Types.Quaternion,
  speed: SG.Types.Number,
});
```

As you can see, you get a basic type inheritance system, composition, and some
predefined types. For a complete description of these, see the documentation.
**TODO: doc**

### Create and share objects

Then you can add objects to a scene by calling the `SG.Scene::add` method. The
base principle is that you must give some Javascript object of your choosing
(for example a BABYLON mesh) which has all the fields you specified in your
type definitions, plus the field `type`.

The `SG.Scene::add()` method will add your object to the scene and immediately
start to synchronize it with other players of the same scene.

```javascript
// The class MyShip defines a property `type = 'Ship'`
var my_ship = new MyShip({
  mesh: {
    position: {x: 1, y: 2, z: 3},
    rotation: {x: 0, y: 0, z: 0, w: 1},
  },
  sound_file: 'vroom.ogg',
  class: 'fighter',
});

scene.add(my_ship);
```

### Receive new objects

You will start receiving objects as soon as you call the `SG.Scene::subscribe`
method. By default, the newly received objects will be instanciated as plain JS
objects. If you want to use instances of you own classes, you should define
factories using `SG.factory()`. The factory of a given object type must return
an object that will be tracked and updated by the scene graph.

```javascript
if (Meteor.isClient) {
  /*
   * On the client, we need to create a new 3D object when a new ship
   * joins the battlefield and when someone shoots a laser ray.
   */
  SG.factory('Ship', function(ship) {
    if (ship.class == 'destroyer') {
      return new DestroyerShip();
    } else {
      /*
       * No need the check the contents of `ship.class',
       * it's already been verified by the scenegraph when
       * we received the object, so it can only be `destroyer'
       * or `fighter'.
       */
      return new FighterShip();
    }
  });

  SG.factory('Laser', function() {
    /*
     * The returned object will be updated with the fields that
     * we just received, and its 'sg_before/after_update()' methods
     * will be called. See section *Receive data updates*.
     */
    return new Laser();
  });
}
```

Note: when using inheritance or aggregation, only the top-level object will be
created using the factory. All the base classes and members of the returned
object are supposed to be fully constructed by the top-level factory. Their
factories won't be called.

### Use the synchronized objects

You can get a synchronized object in two ways:
1. You created it yourself and gave it to `SG.Scene::add()`
2. You received the object through `SG.added()`

In both cases, your object is now part of the scene graph and will directly
receive updates and events. It will have a new property named `__sg_data`
where the internal accounting data is stored.

#### Receive data updates

By default, whenever the remote scene object changes, your local synchronized
copy is updated directly by putting the new data into the properties that you
defined in your type. The object will be informed of the changes with two
callbacks:

1.  If you need to be notified after your object has been updated, add a
    `sg_after_update(fields)` callback. `fields` is an object that contains
    only the updated fields with their new values.

2.  TODO maybe: `sg_before_update(fields)` 

#### Push data updates

Just write to your object's fields and call `SG.update(object)` when you're ready
to share. If you modified only some fields, you can specify what changed in a
second argument.

```javascript
my_ship.position.x += 20;
my_ship.class = 'destroyer';
SG.update(my_ship, {
  position: {x: true},
  class: true;
});
```

TODO: detect automatically which fields changed

#### Removal

To remove an object, call `SG.remove(object)`. When an object is removed
remotely, its function `sg_before_remove()` will be called locally.

Ideas for improvement
---------------------

-   To do some processing using the old data before putting new values in your
    object's fields, you can add a `sg_before_update(fields)` method to your
    object. `fields` contains the changed fields with their new values. If a
    field was removed from the object then it will be present in `fields` with
    a value of `undefined`.  If this method is present, it's up to you to copy
    the data to your object's fields.  **TODO return something to indicate that
    you will do the update yourself, but by default it will be done by the
    scenegraph.**

-   Publish only the surroundings of a given position?

-   Maybe a function like `SG.dispatchUpdates()` to update all objects at
    a specific moment (instead of continuously as network events arrive)?

-   Allow exchange of events between objects? Because synchronization does not allow
    two objects of different types to communicate. Should the scenegraph be handling
    communications? We have unique object identifiers though (node ids).

-   Reactive fields with SG.Types.Reactive(...) decorator... or just,
    if we encouter a reactive variable we use the get/set functions

-   Every newly created object, either plain or produced by a factory, will be
    passed to a callback that you can specify for each type and/or for any
    type, using the `SG.added()' method.

    ```javascript
    SG.added('Noisy', function(noisy) {
      Audio.play(noisy.sound_file);
    });
    
    SG.added('Mesh', function(mesh) {
      Canvas.add_mesh(mesh);
    });
    
    SG.added(function(object) {
      Notifications.message("New " + object + " on the map!");
    });
    ```
    
    Problem: callbacks called for inheritance, not composition?
    * ex: Ship < Noisy → SG.added('Noisy') called
    * ex: Ship { engine: Noisy } → SG.added('Noisy') called?
