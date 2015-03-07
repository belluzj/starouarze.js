Package.describe({
  name: 'belluzj:meteor-scenegraph',
  summary: 'A game scenegraph',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function (api) {
  api.versionsFrom('1.0');
  api.use('coffeescript');
  api.use('underscore');
  api.use('check');
  api.use('mongo');
  api.use('ejson');
  api.addFiles([
    'lib/exports.coffee', // Must be the first file, defines SG
    'lib/testexports.coffee', // Include this file when testing
    'lib/types.coffee',
    'lib/node.coffee',
    'lib/store.coffee',
    'lib/scenegraph.coffee',
  ]);
  api.addFiles('server/scenegraph.coffee', 'server');
  api.export('SG');
});

Package.onTest(function (api) {
  api.use('check');
  api.use('tinytest');
  api.use('underscore');
  api.use('coffeescript');
  api.use('test-helpers');
  api.use('practicalmeteor:sinon');
  api.use('belluzj:meteor-scenegraph');
  api.addFiles([
    'tests/tests.coffee',
    'tests/types.coffee',
    'tests/node.coffee',
  ]);
});
