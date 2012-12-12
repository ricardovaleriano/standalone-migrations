The desires from developers and users can be aggregated here. If you want to
contribute for this project, this is a good place to look for something todo.

Enhancement
===========
 - Better specs organization. We are starting to see unintended dependencies
   between runs.
    - Well, a good way is just to support these tests:
      https://github.com/rails/rails/tree/7174307bd8b7ddb0bd3ec1a5937f03e8ce80a5e4/activerecord/test/cases/tasks
 - Use rspec 'tags' instead of separate tasks for slow tests
 - Use https://github.com/defunkt/fakefs in the file system tests.

Features
========
* Multiple databases:
  - One should be able of indicate any path with a db/config.yml file to run
    migrations
  - Support to any/path/.standalone_migrations file
* Build an executable to allow run usefull Rails scripts like dbconsole
  - maybe this executable can provide a project skeleton generator?
* Use the environemnt variable DATABASE_URL instead of the current Configurator#on
  method

Documentation
=============
* Explain the syntax to pass options for the db:new_migration task.
