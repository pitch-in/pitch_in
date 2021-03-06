'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var StatsPlugin = require('stats-webpack-plugin');

var SOURCE_DIR = path.join(__dirname, './src/');
var DIST_DIR = path.join(__dirname, '../priv/static/');

module.exports = {
  // The entry file. All your app roots fromn here.
  entry: [
    path.join(SOURCE_DIR, 'index.ts')
  ],
  // Where you want the output to go
  output: {
    path: DIST_DIR,
    filename: '[name].min.js',
    publicPath: '/'
  },
  resolve: {
    // Add .ts
    extensions: ["", ".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
  },
  plugins: [
    // webpack gives your modules and chunks ids to identify them. Webpack can vary the
    // distribution of the ids to get the smallest id length for often used ids with
    // this plugin
    new webpack.optimize.OccurenceOrderPlugin(),
    // extracts the css from the js files and puts them on a separate .css file. this is for
    // performance and is used in prod environments. Styles load faster on their own .css
    // file as they dont have to wait for the JS to load.
    new ExtractTextPlugin('[name].min.css'),
    // handles uglifying js
    // new webpack.optimize.UglifyJsPlugin({
    //   compressor: {
    //     warnings: false,
    //     screw_ie8: true
    //   }
    // }),
    // creates a stats.json
    new StatsPlugin('webpack.stats.json', {
      source: false,
      modules: false
    }),
    // plugin for passing in data to the js, like what NODE_ENV we are in.
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ],

  // tslint options
  tslint: {
    emitErrors: false,
    failOnHint: true,
    configuration: require('../.tslint.json')
  },

  module: {
    // Runs before loaders
    preLoaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loader: 'tslint-loader'
    }],
    // loaders handle the assets, like transforming sass to css or jsx to js.
    loaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loaders: ['babel-loader', 'ts-loader']
    }, {
      // foundation needs to be run through babel.
      test: /node_modules\/foundation-sites\/.*\.jsx?$/,
      loaders: ['babel-loader']
    }, {
      test: /\.json?$/,
      loader: 'json'
    }, {
      test: /\.scss$/,
      exclude: [/node_modules/], // sassLoader will include node_modules explicitly.
      // we extract the styles into their own .css file instead of having
      // them inside the js.
      loader: ExtractTextPlugin.extract('style', 'css!postcss!resolve-url!sass')
    }, {
      test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
      loader: 'url?limit=10000&mimetype=application/font-woff'
    }, {
      test: /favicon\.ico$/,
      loader: 'file?name=[name].[ext]&context=src'
    }, {
      test: /\.txt$/,
      loader: 'file?name=[path][name].[ext]&context=src'
    }, {
      test: /\.(png|jpg|svg)(\?[a-z0-9#=&.]+)?$/,
      // loader: 'url?limit=10000&name=img-[hash:6].[ext]'
      loader: 'file?name=[path][name].[ext]&context=src'
    }, {
      test: /\.(ttf|eot)(\?[a-z0-9#=&.]+)?$/,
      loader: 'file'
    }]
  },
  postcss: [
    require('autoprefixer')
  ],
  sassLoader: {
    includePaths: [path.resolve(__dirname, "./node_modules")]
  }
};
