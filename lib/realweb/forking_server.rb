require 'realweb/server'

module RealWeb
  class ForkingServer < Server

    def stop
      kill_pid
      super
    end

    protected

    def kill_pid
      return unless @pid
      Process.kill 'INT', @pid
      Process.kill 'TERM', @pid
      Process.wait @pid
    rescue
      # noop
    ensure
      @pid = nil
    end

    def spawn_server
      @reader, @writer = IO.pipe

      if @pid = fork
        process_as_parent
      else
        process_as_child
      end
    end

    def process_as_parent
      @writer.close
      @host, @port = @reader.read.split(':')
    end

    def process_as_child
      trap(:TERM) { exit!(0) }
      @reader.close
      @server = rack_server
      @writer << "#{@server.options[:Host]}:#{@server.options[:Port]}"
      @writer.close
      @server.start
    end
  end
end
