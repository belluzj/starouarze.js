
Meteor.publish 'userData', ->
  if @userId
    console.log('publish user data')
    return Meteor.users.find @userId,
      fields: # List of fields available to the client
        round_id: 1
  @ready()

Meteor.publish 'openRounds', ->
  console.log('publish open rounds')
  Rounds.find {missing_users: {$gt: 0}}

Meteor.publish 'currentRound', ->
  if @userId
    user = Meteor.users.findOne @userId
    if user.round_id
      return Rounds.find user.round_id
  @ready()

Meteor.publish 'scenegraph', ->
  if @userId
    user = Meteor.users.find @userId
    if user.round_id
      return Scenegraph.find {round_id: user.round_id}
  @ready()



