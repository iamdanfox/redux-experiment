var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    feature1: './index.coffee',
  },
  output: {
    path: path.join(__dirname, 'dist'),
    filename: '[name].js'
  },
  externals: {
    react: 'React'
  },
  module: {
    loaders: [{
      test: /\.js$/,
      loaders: ['babel'],
      exclude: /node_modules/,
      include: __dirname
    }, {
      test: /\.coffee$/,
      loaders: ['coffee-loader', 'cjsx-loader'],
      exclude: /node_modules/,
      include: __dirname
    }]
  }
};
