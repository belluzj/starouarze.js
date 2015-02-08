# Test that all needed functions are exported

Tinytest.add 'meteor-scenegraph - Common exports', (test) ->
  test.isTrue _.isObject(SG), "SG not exported"
  test.isTrue _.isFunction(SG.type), "SG.type not exported"
  test.isTrue _.isObject(new SG.Scene "test"), "SG.Scene not a class"

if Meteor.isServer
  Tinytest.add 'meteor-scenegraph - Server exports', (test) ->
    test.isTrue _.isFunction(SG.allow), "SG.allow not exported"
    test.isTrue _.isFunction(SG.publish), "SG.publish not exported"


