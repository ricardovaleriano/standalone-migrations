module StandaloneMigrations

  module NamespacedTasks

    class TaskGenerator

      def generate_for_all_found_subprojects
        create_tasks_dir
        generate_task_file_for_dirs(subprojects_dirs)
      end

      private

      def tasks_dir_path
        @tasks_dir_path ||= "tasks"
      end

      def create_tasks_dir
        FileUtils.mkdir_p tasks_dir_path unless File.directory? tasks_dir_path
      end

      def subprojects_dirs
        Discoverer.new.subdirs_config_file.map do |config_path|
          File.expand_path("../", config_path)
        end
      end

      def generate_task_file_for_dirs(dirs)
        dirs.each do |dir|
          # saber o dir aqui é importante para colocar essa config
          # no arquivo da task mais prá frente...
          # (como saber de onde veio a config...)
          file_name = Pathname.new(dir).basename.to_s + "_tasks.rb"
          file_path = File.join(tasks_dir_path, file_name)
          FileUtils.touch(file_path) unless File.exists? file_path
        end
      end

    end

  end
end
