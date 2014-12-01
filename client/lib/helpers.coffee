Template.registerHelper 'contains', (array, elem) ->
  elem in array

Template.registerHelper 'length', (array) ->
  array?.length
