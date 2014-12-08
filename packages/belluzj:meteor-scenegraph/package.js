Package.describe({
  name: 'belluzj:meteor-scenegraph',
  summary: 'A game scenegraph',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use('coffeescript');
  api.use('underscore');
  api.use('check');
  api.use('mongo');
  api.addFiles([
    'lib/export.coffee', // Must be the first file, defines SG
    'lib/types.coffee',
    'lib/node.coffee',
    'lib/store.coffee',
    'lib/scenegraph.coffee',
  ]);
  api.addFiles('server/scenegraph.coffee', 'server');
  api.addFiles('client/scenegraph.coffee', 'client');
  api.export('SG');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('belluzj:meteor-scenegraph');
  api.addFiles('tests/tests.coffee');
});
