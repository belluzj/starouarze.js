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
`SG.subscribe` implement the same concept as `Meteor.publish` and
`Meteor.subscribe`, except that the only thing the publish callback does is
check whether it's okay to publish the scene.

```javascript
// On the server
SG.publish('my_scenegraph', function(scene_id) {
  if (this.userId && ... ) {
    return true;
  }
  return false;
});

// On the client
SG.subscribe('my_scenegraph', Meteor.user().my_scene_id);
```

### Create and share objects

By defaults all managed objects carry these minimal data:
* `type`: type of this object
* `scene_id`: the scene of this object
* `parent`: if defined, another managed object that is the parent

The type information is very important, because that's how you will be able to "inflate" the received nodes into real JS objects, and how the synchronization mechanism knows which fields to synchronize. You must therefore specify for each type a list of meaningful fields that should be taken care of:

```javascript
// On both sides

// Data types
SG.type('Mat22', [], {
  a: SG.Types.Number,
  b: SG.Types.Number,
  c: SG.Types.Number,
  d: SG.Types.Number,
});

// Node types
SG.type('Base', ['Node'], {
  position: SG.Types.Vec3,
  rotation: SG.Types.Optional(SG.Types.Quat),
});

SG.type('Noisy', ['Node'], {
  sound_file: SG.Types.String,
});

SG.type('Ship', ['Base', 'Noisy'], {
  class: SG.Types.Enum(['destroyer', 'fighter']),
});

SG.type('Laser', ['Noisy'], {
  start_pos: SG.Types.Vec3,
  direction: SG.Types.Quat,
  speed: SG.Types.Number,
});
```

As you can see, you get a basic type inheritance system and some predefined
types. For a complete description of these, see the documentation. **TODO: doc**

Then you can add objects to a scene by calling the `SG.add` method. The base
principle is that you must give some Javascript object of your choosing (for
example a BABYLON mesh) which has all the fields you specified in your type
definitions, plus the field `type`.

```javascript
// The class MyShip defines a property `type = 'ship'`
var my_ship = new MyShip({
  position: {x: 1, y: 2, z: 3},
  rotation: {x: 0, y: 0, z: 0, w: 1},
  sound_file: 'vroom.ogg',
  class: 'fighter',
});

SG.add(scene_id, my_ship);
```

The `SG.add()` method will add your object to the scene and immediately start to
synchronize it with other players of the same scene.

### Receive new objects

Use `SG.added()` in order to receive new objects for a specific scene. On the
client, you must subscribe to the scene beforehand.

The semantics are: create a new empty object of the right type and return it.
The object will then be updated with the actual data that was added to the
scene.

```javascript
// Anywhere
SG.added(scene_id, function (type) {
  // Create a new object of the given type and return it
  if (type == 'ship') {
    return new MyShip();
  }
});
```

### Use the synchronized objects

You can get a synchronized scene object in two ways:
1. You created it yourself and gave it to `SG.add()`
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



