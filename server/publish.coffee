
Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find @userId,
      fields: # List of fields available to the client
        round_id: 1
  @ready()

Meteor.publish 'openRounds', ->
  if @userId
    return Rounds.find $or: [
      {missing_users: {$gt: 0}},
      {user_ids: @userId}
    ]
  @ready()

Meteor.publish 'currentRound', ->
  if @userId
    user = Meteor.users.findOne @userId
    if user.round_id
      return Rounds.find user.round_id
  @ready()

SG.publish (scene_id) ->
  if @userId
    user = Meteor.users.findOne @userId
    user.round_id == scene_id
  else
    false



