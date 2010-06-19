require 'realweb/server'

module RealWeb
  class ThreadServer < Server

    def stop
      @thread.kill if @thread
      super
    end

    protected

    def spawn_server
      return if @thread && @thread.alive?

      @thread ||= Thread.new do
        rack_server.start
      end
    end
  end
end
