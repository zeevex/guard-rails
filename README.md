[![Build Status](http://travis-ci.org/johnbintz/guard-rails.png)](http://travis-ci.org/johnbintz/guard-rails)

Want to restart your Rails development server whilst you work? Now you can!

    guard 'rails', :port => 5000 do
      watch('Gemfile.lock')
      watch(%r{^(config|lib)/.*})
    end

Lots of fun options!

* `:port` is the port number to run on (default `3000`)
* `:environment` is the environment to use (default `development`)
* `:start_on_start` will start the server when starting Guard (default `true`)
* `:force_run` kills any process that's holding open the listen port before attempting to (re)start Rails (default `false`).
* `:daemon` runs the server as a daemon, without any output to the terminal that ran `guard` (default `false`).
* `:timeout` waits this number of seconds when restarting the Rails server before reporting there's a problem (default `20`).
* `:rails_version` sets the rails major version; for version 3 uses "rails s" to launch, for version 2 uses "rackup" to launch, which requires a config.ru file (default `3`).
* `:hide_output` sends stdout to /dev/null if true (default `false`)

Example RAILS_ROOT/config.ru file for Rails 2.3:

    require "config/environment"
    
    use Rails::Rack::LogTailer
    use Rails::Rack::Static
    run ActionController::Dispatcher.new

This is super-alpha, but it works for me! Only really hand-tested in Mac OS X. Feel free to fork'n'fix for other
OSes, and to add some more real tests.

