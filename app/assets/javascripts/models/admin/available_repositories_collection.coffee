### define
underscore : _
backbone : Backbone
###

class AvailableRepositoriesCollection extends Backbone.Collection

  constructor : ->

    # Fetch the data with AJAX
    # $.ajax or Backbone.Model.fetch ....
    data = [
      {repository: "scalableminds/auth-proxy"},
      {repository: "scalableminds/autodeploy"},
      {repository: "scalableminds/backbone-deep-model"},
      {repository: "scalableminds/BFTeaser"},
      {repository: "scalableminds/BPG1"},
      {repository: "scalableminds/brainflight"},
      {repository: "scalableminds/braingames-backend"},
      {repository: "scalableminds/braingames-libs"},
      {repository: "scalableminds/campusinform"},
      {repository: "scalableminds/coffee-preroast"},
      {repository: "scalableminds/coffee-script"},
      {repository: "scalableminds/deployboy-ui"},
      {repository: "scalableminds/evolution"},
      {repository: "scalableminds/generator-backbone-amd"},
      {repository: "scalableminds/git-jira"},
      {repository: "scalableminds/grunt-coffeelint"},
      {repository: "scalableminds/grunt-contrib-coffee"},
      {repository: "scalableminds/grunt-image-resize"},
      {repository: "scalableminds/hubot"},
      {repository: "scalableminds/human-view"},
      {repository: "scalableminds/incubator-cordova-android"},
      {repository: "scalableminds/jenkins"},
      {repository: "scalableminds/mhlablog"},
      {repository: "scalableminds/oxalis"},
      {repository: "scalableminds/Play-ReactiveMongo"},
      {repository: "scalableminds/playframework"},
      {repository: "scalableminds/problemkind"},
      {repository: "scalableminds/qassert"},
      {repository: "scalableminds/ReactiveMongo"},
      {repository: "scalableminds/saltyscm"},
      {repository: "scalableminds/scalableminds.github.com"},
      {repository: "scalableminds/scm.io"},
      {repository: "scalableminds/shellgame-assets"},
      {repository: "scalableminds/shellgame2"},
      {repository: "scalableminds/shootit"},
      {repository: "scalableminds/stry"},
      {repository: "scalableminds/styleguide"},
      {repository: "scalableminds/time-tracker"},
      {repository: "scalableminds/viz.js"},
      {repository: "scalableminds/wintersmith-coffee"},
      {repository: "scalableminds/worker-untar-pngdecode-demo"},
    ]

    super(data)