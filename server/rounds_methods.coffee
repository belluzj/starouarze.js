Meteor.methods
  createRound: (round) ->
    # console.log('create round', round)
    if not @userId
      throw new Meteor.Error 'no-user'
    check round,
      name: String
      nb_users: Number
    if round.name.length == 0
      throw new Meteor.Error 'empty-name'
    if round.nb_users <= 0
      throw new Meteor.Error 'empty-round'
    round.missing_users = round.nb_users
    round.user_ids = []
    # console.log('insert round', round)
    round_id = Rounds.insert round
    # console.log('got round id', round_id)
    Meteor.call 'joinRound', round_id

  joinRound: (round_id) ->
    # console.log('join round', round_id)
    check round_id, String
    if not @userId
      throw new Meteor.Error 'no-user'
    Meteor.call 'leaveRound'
    that = @
    Rounds.update {
      _id: round_id
      missing_users: {$gt: 0}
      user_ids: {$ne: @userId}
    }, {
      $inc: {missing_users: -1}
      $push: {user_ids: @userId}
    }, (error, nb_updated) ->
      # console.log('joined round', error, nb_updated)
      if error
        #TODO
      else if nb_updated == 1
        Meteor.users.update that.userId,
          $set: {round_id: round_id}

  leaveRound: ->
    # console.log('leave round')
    if not @userId
      throw new Meteor.Error 'no-user'
    that = @
    Rounds.update {
      #missing_users: {$gt: 0} # Can't leave a complete round?
      user_ids: @userId
    }, {
      $inc: {missing_users: 1}
      $pull: {user_ids: @userId}
    }, (error, nb_updated) ->
      # console.log('left round', error, nb_updated)
      if error
        #TODO
      else if nb_updated == 1
        Meteor.users.update that.userId,
          $set: {round_id: null}

