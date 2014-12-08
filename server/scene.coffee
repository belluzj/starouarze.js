# Validations of scene graph updates

SG.allow
  insert: (userId, object) ->
    # TODO check game rules (do not allow overshooting lasers...)
    if userId
      user = Meteor.users.findOne userId
      object.scene_id == user.round_id and object.owner_id == userId
    else
      false
  update: (userId, object, new_fields) ->
    # TODO avoid teleportation
    if userId
      user = Meteor.users.findOne userId
      object.scene_id == user.round_id and object.owner_id == userId
    else
      false
  remove: (userId, object) ->
    # TODO 
    if userId
      user = Meteor.users.findOne userId
      object.scene_id == user.round_id and object.owner_id == userId
    else
      false
