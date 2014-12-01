Meteor.publish 'openRounds', ->
  Rounds.find {missingUsers: {$gt: 0}}
