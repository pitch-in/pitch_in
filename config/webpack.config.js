'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

var publicPath = 'http://localhost:4001';
var SOURCE_DIR = path.join(__dirname, '../web/static/');
var DIST_DIR = path.join(__dirname, '../priv/static/');

module.exports = {
  devtool: 'cheap-eval-source-map',
  entry: [
    'webpack-dev-server/client?' + publicPath,
    'webpack/hot/only-dev-server',
    // 'react-hot-loader/patch',
    path.join(SOURCE_DIR, 'index.ts')
  ],
  output: {
    path: DIST_DIR,
    filename: '[name].js',
    publicPath: publicPath + '/'
  },
  resolve: {
    // Add .ts
    extensions: ["", ".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
  },
  plugins: [
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('development')
    })
  ],
  // tslint options
  tslint: {
    emitErrors: false,
    failOnHint: false,
    configuration: require('../.tslint.json')
  },
  module: {
    preLoaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loader: 'tslint-loader'
    }],
    loaders: [
      // All files with a '.ts' or '.tsx' extension will be handled by 'ts-loader'.
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        loaders: ['babel-loader', 'ts-loader']
      }, {
        // foundation needs to be run through babel.
        test: /\.jsx?$/,
        // exclude: /node_modules/,
        loaders: ['babel-loader']
      }, {
        test: /\.json?$/,
        loader: 'json-loader'
      }, {
        test: /\.scss$/,
        exclude: [/node_modules/], // sassLoader will include node_modules explicitly.
        loader: 'style!css!resolve-url!sass?modules&localIdentName=[name]---[local]---[hash:base64:5]'
      }, {
        test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
        loader: 'url?limit=10000&mimetype=application/font-woff'
      }, {
        test: /\.(png|jpg|svg)(\?[a-z0-9#=&.]+)?$/,
        // loader: 'url?limit=10000&name=img-[hash:6].[ext]'
        loader: 'file?name=[path][name].[ext]&context=web/static'
      }, {
        test: /favicon\.ico$/,
        loader: 'file?name=[name].[ext]&context=web/static'
      }, {
        test: /\.txt$/,
        loader: 'file?name=[path][name].[ext]&context=web/static'
      }, {
        test: /\.(ttf|eot)(\?[a-z0-9#=&.]+)?$/,
        loader: 'file'
      }
    ]
  },
  sassLoader: {
    includePaths: [path.resolve(__dirname, "../node_modules")]
  }
};
