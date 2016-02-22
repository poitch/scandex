require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |spec|
    spec.name = "scandex"
    spec.version = ScanDex::VERSION
    spec.authors = ["Jerome Poichet"]
    spec.email = "poitch@gmail.com"
    spec.homepage = "http://github.com/poitch/scandex"
    spec.summary = "Index your scanned paper documents"
    spec.executables = %w(scandex)
    spec.add_dependency 'rtesseract'
    spec.add_dependency 'rmagick'
    spec.add_dependency 'sqlite3'
    spec.add_dependency 'thor'
    spec.add_dependency 'filewatcher'
    spec.add_dependency 'gems'
    spec.files = Dir.glob(%w[{lib}/*.rb bin/*])
    spec.require_paths << "lib"
end

