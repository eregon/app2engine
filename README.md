# app2engine

Convert a Rails 3 app to an Engine.

The structure of a standard Rails application is very similar to what you need for an Engine.

But a few details need to be changed.

This tool intend to do most of them for you.

## Install

    gem install app2engine

## Synopsis

Create an new app to convert it to an Engine (avoid using underscores):

    rails new myengine

Run `app2engine` in the root directory of this app you want to make an Engine:

    app2engine

Then convert it with Rake:

    rake engine:convert # or simply rake engine

Follow the instructions: To the main app's Gemfile, add

    gem 'myengine', :path => 'path/to/myengine'

Use extras if you want:

    rake engine:extra

## You are done setting up your engine

If you want a little test:

In your engine's dir:

    rails g controller engine myaction

In your main app's dir:

    rails g controller base myaction

`rails s` and surf on `/engine/myaction` and `/base/myaction` !

(You can also verify routing is fine with `rake routes`)

## Author

Benoit Daloze
