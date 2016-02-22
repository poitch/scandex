require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |spec|
    spec.name = "scandex"
    spec.version = ScanDex::VERSION
    spec.authors = ["Jerome Poichet"]
    spec.email = "poitch@gmail.com"
    spec.homepage = "http://github.com/poitch/scandex"
    spec.summary = "Index your scanned paper documents"
    spec.description = "A very simple tool to index scanned documents in either PDF or image format"
    spec.license = "MIT"
    spec.executables = %w(scandex)
    spec.add_dependency 'rtesseract', '1.3.2'
    spec.add_dependency 'rmagick', '2.15.4'
    spec.add_dependency 'sqlite3', '1.3.11'
    spec.add_dependency 'thor', '0.19.1'
    spec.add_dependency 'filewatcher', '0.5.3'
    spec.add_dependency 'gems', '2.4.6'
    spec.files = Dir.glob(%w[{lib}/*.rb bin/*])
    spec.require_paths << "lib"
end

