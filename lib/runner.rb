require 'thor'
require 'filewatcher'
require_relative 'scandex'

class Runner < Thor
    class_option :f, :banner => "Directory where to store index"

    desc "doctor", "Checks system to make sure everything is installed properly"
    def doctor
        ScanDex::doctor()
    end

    desc "list", "List all documents indexed"
    def list
        files = ScanDex::documents(options[:f])
        files.each do |file|
            puts "#{file[0]} #{file[1]}"
        end
    end

    desc "index FILES", "Index scanned FILES"
    option :force, :type => :boolean
    def index(*files)
        # If doctor fails then there is no point in even trying
        if !ScanDex::doctor()
            return
        end
        files.each do |file|
            ScanDex::index_and_store(options[:f], file, options[:force])
       end
    end

    desc "search TERM", "Search documents containing TERM"
    def search(term)
        files = ScanDex::search_documents(options[:f], term)
        files.each do |file|
            puts "#{file[0]} #{file[1]}"
        end
    end

    desc "watch DIRECTORIES", "Watch DIRECTORIES for new files to index"
    def watch(*directories)
        FileWatcher.new(directories).watch do |file, event|
            if (event == :changed || event == :new)
                ScanDex::index_and_store(options[:f], file, true)
            end
        end
    end
end

