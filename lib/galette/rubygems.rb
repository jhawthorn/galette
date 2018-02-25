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
        @versions = parse(response.body)
      end

      def all_dependant_gems
        versions.values.flatten(1).map(&:first).uniq
      end

      private

      def parse(body)
        versions = {}
        body.lines.reject do |line|
          line == "---\n"
        end.map do |line|
          if line =~ /\A(\S+) (.*)\|checksum:(.+)\n\z/
            version = $1

            # Skip platformed gems for now
            next if version.include?('-')

            deps = $2.split(',').map do |dep|
              name, requirements = dep.split(':', 2)
              [name, requirements.split('&')]
            end
            versions[version] = deps
          else
            raise "couldn't parse line: #{line}"
          end
        end
        versions
      end
    end

    def self.fetch_gem(name)
      FetchedInfo.new(name)
    end

    def self.specs_from_requirements(requirements)
      if requirements.is_a?(Array)
        requirements = Hash[
          requirements.map { |s| [s, []] }
        ]
      end

      # Assume our current version of ruby and rubygems
      all_gems = {
        'rubygems' => {Gem::VERSION => []},
        'ruby' => {RUBY_VERSION => []}
      }

      # Fetch all possible required gems from compact index
      queue = requirements.keys
      while !queue.empty?
        name = queue.shift
        next if all_gems.key?(name)

        gem = fetch_gem(name)
        all_gems[name] = gem.versions
        queue.concat(gem.all_dependant_gems)
      end

      all_gems = Hash[all_gems]

      # Second pass sets up specifications with all versions but no requirements
      specifications = Hash[
        all_gems.map do |gem_name, gem_versions|
          specification = Galette::Specification.new(gem_name) do |spec|
            gem_versions.keys.reverse.each do |version|
              spec.version version
            end
          end

          [gem_name, specification]
        end
      ]

      # Second pass adds requirements to each version
      specifications.values.each do |specification|
        specification.versions.each do |version|
          next if version.none?
          version_requirements = all_gems[specification.name][version.version]
          version_requirements.each do |requirement_name, requirement_version_spec|
            availability = specifications[requirement_name].requirement_semver(requirement_version_spec)
            version.requirements &= availability
          end
        end
      end

      # Finally we apply the initial requirements to form an AvailabilitySet
      Galette::AvailabilitySet.new(
        specifications.values.map do |specification|
          if requirements.has_key?(specification.name)
            specification.requirement_semver(requirements[specification.name])
          else
            specification.full_availability
          end
        end
      )
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
