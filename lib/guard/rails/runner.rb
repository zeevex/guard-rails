module Guard
  class RailsRunner
    MAX_WAIT_COUNT = 10

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def start
      kill_unmanaged_pid! if options[:force_run]
      run_rails_command!
      count = 0
      while !has_pid? && count < MAX_WAIT_COUNT
        wait_for_pid_action
        count += 1
      end
      !(count == MAX_WAIT_COUNT)
    end

    def stop
      if File.file?(pid_file)
        system %{kill -INT #{File.read(pid_file).strip}}
      end
    end
    
    def restart
      stop
      start
    end

    def build_rails_command
      case rails_version
        when 2 then build_rails_command_2
        when 3 then build_rails_command 3
        else raise ArgumentError, "Unknown rails version: #{rails_version}"
      end
    end

    def build_rails_command_2
      rails_options = [
        '-E', options[:environment],
        '-p', options[:port],
        '--pid', pid_file
      ]

      rails_options << '-D' if options[:daemon]

      %{sh -c 'cd #{Dir.pwd} && rackup #{rails_options.join(' ')} &'}
    end

    def build_rails_command_3
      rails_options = [
        '-e', options[:environment],
        '-p', options[:port],
        '--pid', pid_file
      ]

      rails_options << '-d' if options[:daemon]

      %{sh -c 'cd #{Dir.pwd} && rails s #{rails_options.join(' ')} &'}
    end

    def pid_file
      File.expand_path("tmp/pids/#{options[:environment]}.pid")
    end

    def pid
      File.file?(pid_file) ? File.read(pid_file).to_i : nil
    end

    def sleep_time
      options[:timeout].to_f / MAX_WAIT_COUNT.to_f
    end

    private
    
    def rails_version
      options[:rails_version] || 3
    end
    
    def run_rails_command!
      system build_rails_command
    end

    def has_pid?
      File.file?(pid_file)
    end

    def wait_for_pid_action
      sleep sleep_time
    end

    def kill_unmanaged_pid!
      if pid = unmanaged_pid
        system %{kill -INT #{pid}}
      end
    end

    def unmanaged_pid
      if RbConfig::CONFIG['host_os'] =~ /darwin/
        %x{lsof -P}.each_line { |line|
          if line["*:#{options[:port]} "]
            return line.split("\s")[1]
          end
        }
      end
      nil
    end
  end
end

