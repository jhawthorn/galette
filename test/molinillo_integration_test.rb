require 'test_helper'
require 'json'
require 'minitest/spec'

describe "Molinillo Integration Test" do
  CASES_DIR = File.expand_path('molinillo_integration_specs/case', __dir__)
  INDEX_DIR = File.expand_path('molinillo_integration_specs/index', __dir__)

  def index_to_specifications(index)
    specifications = Hash[
      index.map do |name, versions|
        [
          name,
          Galette::Specification.new(name) do |s|
            versions.each do |index_version|
              s.version index_version["version"]
            end
          end
        ]
      end
    ]

    dependencies = Hash[
      index.map do |name, versions|
        [name, Hash[versions.map{|x| [x["version"], x["dependencies"]] }]]
      end
    ]

    specifications.values.each do |s|
      s.versions.each do |version|
        next unless version.version
        deps = dependencies[s.name][version.version]
        version.requirements &= Galette::AvailabilitySet.new(
          deps.map do |name, req|
            next unless specifications[name]
            req = req.split(', ')
            specifications[name].requirement_semver(req)
          end.compact
        )
      end
    end

    specifications
  end

  Dir[File.join(CASES_DIR, '*.json')].each do |case_file|
    case_data = JSON.parse(File.read(case_file))

    # FIXME
    next unless case_data['base'].empty?

    it case_data["name"] do
      puts case_data["name"]
      requested = case_data["requested"]
      index_name = case_data["index"] || "awesome"
      index_data = JSON.parse(File.read(File.join(INDEX_DIR, "#{index_name}.json")))

      puts "loading index..."
      specifications = index_to_specifications(index_data)

      puts "calculating requested gems..."
      requested = requested.map do |name, req|
        specifications[name].requirement_semver(req)
      end

      specifications = requested.flat_map do |availability|
        availability.specification.all_dependency_specifications
      end.uniq

      resolution = Galette::Resolution.new(specifications, requested)

      puts "solving..."
      if case_data['conflicts']
        resolution.resolve
      else
        expected = case_data["resolved"]
        actual = resolution.resolve
      end
    end
  end
end
