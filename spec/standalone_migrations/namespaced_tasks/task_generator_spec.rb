module StandaloneMigrations

  module NamespacedTasks

    describe TaskGenerator, "generate tasks for each subdir with a .standalone_migrations file" do

      it "create a tasks/[dir]_tasks.rb" do
        pending
      end

      it "add a load line in the Rakefile after create a subdir specific task file" do
        pending " echo 'load tasks/*' >> Rakefile"

        # quando rodar uma task dentro de um namespace tem que carregar o config
        # específico daquele namespace
      end

    end
  end
end
