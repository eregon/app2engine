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

Follow the instructions:

To the main app's Gemfile, add

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

## Notes

### Namespace them all !

The folders `{controllers,models,views}/myengine` are created because you should namespace your engine.

### Production

In Production environment, you must comment (or set to `true`) the line in mainapp/config/environments/production.rb

Change

    config.serve_static_assets = false

to

    config.serve_static_assets = true # This is needed to serve static assets from engines

Because the engine modify the static assets by appending its own public folder. (A workaround may be to config you server)

### Code reloading / overwriting / load order

This is a discussion about what happen if you want to modify behavior in the mainapp.

#### Models

Models are behaving especially bad with Engines.

In development, you need to load yourself the model, or only the model of the *engine* will be loaded.
To keep the auto-reloading, I only found this workaround (in the *engine*/app/blog/posts.rb):

    if File.exist?(app = Rails.root.join("app/models/blog/posts.rb").to_s)
      load app
    end

This is counter-intuitive as you would feel that the mainapp should load the engine one if redefined.

In production, however, not using this trick works, but letting it will not hurt.

#### Controllers

Controllers of the mainapp overwrite the one of the engine, completely.
(The one of the engine will not be loaded if there is the same in the mainapp)

You then have to load the engine controller yourself, adding this at the top of the mainapp controller:

    load "myengine/app/controllers/test_controller.rb"

There is the problem we do not know how to access that file,
 because loading `app/controllers/test_controller.rb` would require the mainapp controller (again).

So again a workaround, I created a symlink in the mainapp root (called myengine) to the engine root.

In production, you also need to load the file itself (but you could do a simple `require` as it will loaded once, so no need to change anything).

#### Views

Views in the mainapp overwrite the views corresponding in the engine.

This is expected behavior, as you can mainly think that the paths of the engine are appended to the ones of the mainapp.

#### public/ folder, static assets

In development, public assets are served as expected, with the mainapp overwriting the engine.

In production, however, the engine files do not seem to be served at all.
(and if you do not do the trick said upper with serve\_static\_assets, even the mainapp files will not load)

Update:
  It seems it works with changing syntax in the "static assets" initializer of the engine. The gem is then updated.
  (delete your lib/myengine/engine.rb, and call again `rake engine` and `rake engine:extra` if you want)

## Author

Benoit Daloze
