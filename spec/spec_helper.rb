$: << File.join(File.expand_path('../', __FILE__), 'lib')

def read(file)
  File.read(tmp_file(file))
end

def remove_tmp_project_dir
  `rm -rf spec/tmp` if File.exist?('spec/tmp')
end

def tmp_dir
  File.join "spec", "tmp"
end

def tmp_file(file)
  File.join tmp_dir, file
end

def write(file, content)
  raise "cannot write nil" unless file
  file = tmp_file(file)
  folder = File.dirname(file)
  `mkdir -p #{folder}` unless File.exist?(folder)
  File.open(file, 'w') { |f| f.write content }
end

def write_rakefile(config=nil)
  write 'Rakefile', <<-TXT
$LOAD_PATH.unshift '#{File.expand_path('lib')}'
begin
require "standalone_migrations"
StandaloneMigrations::Tasks.load_tasks
rescue LoadError => e
puts "gem install standalone_migrations to get db:migrate:* tasks! (Error: \#{e})"
end
  TXT
end

def prepare_tmp_project_dir
  `rm -rf #{tmp_dir}` if File.exist?('spec/tmp')
  `mkdir #{tmp_dir}`
  write_rakefile
  write 'db/config.yml', <<-TXT
development:
  adapter: sqlite3
  database: db/development.sql
test:
  adapter: sqlite3
  database: db/test.sql
TXT
end

def make_migration(name, options={})
  task_name = options[:task_name] || 'db:new_migration'
  migration = run("rake #{task_name} name=#{name}").match(%r{db/migrate/\d+.*.rb})[0]
  content = read(migration)
  content.sub!(/def down.*?\send/m, "def down;puts 'DOWN-#{name}';end")
  content.sub!(/def up.*?\send/m, "def up;puts 'UP-#{name}';end")
  write(migration, content)
  migration.match(/\d{14}/)[0]
end

def run(cmd)
  original_dir = Dir.pwd
  result = `cd spec/tmp && #{cmd} 2>&1`
  Dir.chdir original_dir
  raise result unless $?.success?
  result
end

def migration(name)
  m = `cd spec/tmp/db/migrate && ls`.split("\n").detect { |m| m =~ /#{name}/ }
  m ? "db/migrate/#{m}" : m
end

def write_multiple_migrations
  write_rakefile %{t.migrations = "db/migrations", "db/migrations2"}
  write "db/migrate/20100509095815_create_tests.rb", <<-TXT
class CreateTests < ActiveRecord::Migration
def up
  puts "UP-CreateTests"
end

def down
  puts "DOWN-CreateTests"
end
end
  TXT
  write "db/migrate/20100509095816_create_tests2.rb", <<-TXT
class CreateTests2 < ActiveRecord::Migration
def up
  puts "UP-CreateTests2"
end

def down
  puts "DOWN-CreateTests2"
end
end
  TXT
end

require 'standalone_migrations'
