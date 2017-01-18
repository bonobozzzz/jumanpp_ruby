require "jumanpp_ruby/version"

module JumanppRuby
  class Juman
    require 'open3'
    
    def initialize(**options)
      @option = []
      @option.tap do |opt|
        opt << "-B #{options[:beam]}" if options[:beam]
        opt << "--force-single-path" if options[:force_single_path] == :true
        opt << "--partial" if options[:partial] == :true
      end
      @pipe ||= IO.popen("jumanpp #{@option.join(' ')}".strip, 'r+')
      binding.pry
    end

    def parse(sentents)
      @pipe.puts(sentents)

      responses = []
      while sentent = @pipe.gets
        responses << sentent.delete("\\").delete("\"")
        break if sentent.match(/EOS\n/)
      end

      if block_given?
        responses.each do |word|
          yield word.split
        end
      else
        responses.map { |word| word.split.first }
      end
    end

    def close
      @pipe.close
    end

    def self.version
      o, = Open3.capture2("jumanpp -v")
      o.strip
    end

    def self.help
      o, = Open3.capture2("jumanpp -h")
      o.strip
    end
  end
end
