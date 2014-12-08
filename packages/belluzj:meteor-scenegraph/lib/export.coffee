# The main library export
@SG = SG = {}

class SG.Error extends Error
  constructor: (message) ->
    @name = 'SceneGraph Error'
    @message = message
