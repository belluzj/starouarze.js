A reactive game scene graph
===========================

The scene graph is a collections of objects that are part of the same game
environment. This package makes it easy to synchronize the contents and state
of such an environment between multiple players and a server, in order to make
a multiplayer game.

How-to
------

### Set up a scene graph

A scene graph is only defined by its id. You should provide it.

In order to synchronize the scene between everyone, `SG.publish` and
`SG.Scene::subscribe` implement the same concept as `Meteor.publish` and
`Meteor.subscribe`.

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

// Anywhere
var scene = new SG.Scene(Meteor.user().my_scene_id);
scene.subscribe();
```

### Create and share objects

An object that is managed by the scene graph must have at least the following
fields:
* `type` (string): the type of this object

The type information is very important, because that's how you will be able to
"inflate" the received nodes into real JS objects, and how the synchronization
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

SG.type('Mesh', {
  position: SG.Types.Vector3,
  rotation: SG.Types.Optional(SG.Types.Quaternion),
});

SG.type('Noisy', {
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

As you can see, you get a basic type inheritance system and some predefined
types. For a complete description of these, see the documentation. **TODO: doc**

Then you can add objects to a scene by calling the `SG.Scene::add` method. The base
principle is that you must give some Javascript object of your choosing (for
example a BABYLON mesh) which has all the fields you specified in your type
definitions, plus the field `type`.

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

The `SG.Scene::add()` method will add your object to the scene and immediately start to
synchronize it with other players of the same scene.

### Receive new objects

Use `SG.Scene::added()` in order to receive new objects for a specific scene.
You must subscribe to the scene beforehand. The given callback must create a
new empty object of the right type and return it.  The object will then be
updated with the actual data that was added to the scene.

```javascript
// Anywhere
scene.added(function (type) {
  // Create a new object of the given type and return it
  if (type == 'ship') {
    return new MyShip();
  }
});
```

TODO object factory

### Use the synchronized objects

You can get a synchronized object in two ways:
1. You created it yourself and gave it to `SG.Scene::add()`
2. You received the object through `SG.added()`

In both cases, your object is now part of the scene graph and will directly
receive updates and events. It will have a new property with a weird name like
`__sg_data` and you should not touch it.

#### Receive data updates

By default, whenever the remote scene object changes, your local synchronized
copy is updated directly by putting the new data into the properties that you
defined in your type. The object will be informed of the changes with two
callbacks:

1. To process the raw data before putting in your object's fields, you can add
   a `sg_before_update(fields)` method to your object. `fields` contains the
   changed fields with their new values. If a field was removed from the object
   then it will be present in `fields` with a value of `undefined`." If this
   method is present, it's up to you to copy the data to your object's fields.
   **TODO**

2. If you need to be notified after your object has been updated, add a
   `sg_after_update(fields)` callback. `fields` is the same array as before.

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

#### Removal

To remove an object, call `SG.remove(object)`. When an object is removed
remotely, its function `sg_before_remove()` will be called locally.

Ideas for improvement
---------------------

1. Make it possible to define new types (to match a 3D engine != BABYLON)

2. Allow nested fields in types?

3. Maybe a function like `SG.dispatchUpdates()` to update individual objects at
   a specific moment?

4. Allow exchange of events between objects?



