require 'net/http'
require 'uri'

module Galette
  module Rubygems
    class FetchedInfo
      attr_reader :name, :versions

      def initialize(name)
        uri = URI.parse("https://index.rubygems.org/info/#{name}")
        puts uri
        response = Net::HTTP.get_response(uri)
        raise "unable to fetch #{name}" unless response.is_a?(Net::HTTPSuccess)
        parse(response.body)
      end

      def all_dependant_gems
        @all_dependant_gems ||=
          versions.values.flatten(1).map(&:first).uniq
      end

      private

      def parse(body)
        @versions = {}
        body.lines.reject do |line|
          line == "---\n"
        end.map do |line|
          if line =~ /\A(\S+) (.*)\|checksum:(.+)\n\z/
            version = $1
            deps = $2.split(',').map { |dep| dep.split(':', 2) }
            versions[version] = deps
          else
            raise "couldn't parse line: #{line}"
          end
        end
      end
    end

    def self.fetch_gem(name)
      FetchedInfo.new(name)
    end

    def self.fetch_all_gems(name)
      all_gems = {
        'rubygems' => [Gem::VERSION],
        'ruby' => [RUBY_VERSION]
      }
      queue = [name]
      while !queue.empty?
        name = queue.shift
        next if all_gems.key?(name)

        gem = fetch_gem(name)
        all_gems[name] = gem
        queue.concat(gem.all_dependant_gems)
      end
      all_gems
    end

    def self.all_versions
      uri = URI.parse('https://index.rubygems.org/versions')
      response = Net::HTTP.get_response(uri)
      raise "unable to fetch full version list" unless response.is_a?(Net::HTTPSuccess)
      gems = response.body.split("---\n", 2)[1]
      gems.lines.map do |line|
        gem, version, _ = line.split(' ')
        [gem, version.split(',')]
      end.to_h
    end
  end
end
