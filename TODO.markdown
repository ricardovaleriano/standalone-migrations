The desires from developers and users can be aggregated here. If you want to
contribute for this project, this is a good place to look for something todo.

Enhancement
===========
 - Better specs organization. We are starting to see unintended dependencies
   between runs.

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
