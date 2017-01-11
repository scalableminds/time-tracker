var webpack = require("webpack");
var ExtractTextPlugin = require('extract-text-webpack-plugin');

var appRoot = __dirname + "/app/assets/javascripts";

module.exports = {
  context: appRoot,
  entry: [
    "./main.coffee",
    "../stylesheets/main.less",
  ],
  output: {
    path: __dirname + "/public",
    filename: "main.js",
    publicPath: "/assets/",
  },
  bail: true,
  resolve: {
    alias: {
      "app"                 : appRoot + "/app",
      "models"              : appRoot + "/models",
      "utils"               : appRoot + "/utils",
      "libs"                : appRoot + "/libs",
      "views"               : appRoot + "/views",
      "marionette"          : appRoot + "/marionette",
      "jquery"              : __dirname + "/bower_components/jquery/dist/jquery",
      "moment"              : __dirname + "/bower_components/momentjs/moment",
      "underscore"          : __dirname + "/bower_components/lodash/dist/lodash",
      "backbone"            : __dirname + "/bower_components/backbone/backbone",
      "backbone.marionette" : __dirname + "/bower_components/backbone.marionette/lib/backbone.marionette",
      "bootstrap"           : __dirname + "/bower_components/bootstrap/dist/js/bootstrap",
      "bootstrap"           : __dirname + "/bower_components/bootstrap/dist/js/bootstrap",
    },
    extensions: ["", ".js", ".coffee"],
  },
  module: {
    loaders: [
      { 
        test: /\.coffee$/, loader: "coffee-loader"
      }, {
        test: /\.less$/,
        loader: ExtractTextPlugin.extract("style", "css!less")
      }, {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style", "css")
      }, {
        test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff"
      }, {
        test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff"
      }, {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/octet-stream"
      }, {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        loader: "file"
      }, {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=image/svg+xml"
      },
    ]
  },
  plugins: [
    new ExtractTextPlugin('main.css'), 
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery",
      Backbone: "backbone",
      _: "underscore",
    }),
  ],
};