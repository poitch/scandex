require 'rtesseract'
require 'sqlite3'

module ScanDex
    def self.tesseract
        `which tesseract`.strip
    end

    def self.gs
        `which gs`.strip
    end

    def self.convert
        `which convert`.strip
    end

    def self.doctor
        convert = self.convert
        if convert.empty?
            puts "ImageMagick is missing"
            return false
        end
        gs = self.gs
        if gs.empty?
            puts "GhostScript is missing"
            return false
        end
        tesseract = self.tesseract
        if tesseract.empty?
            puts "Tesseract is missing"
            return false
        end
        #puts "All Tools Available"
        true
    end

    def self.index_and_store(store_path, file, force = false)
        content = ScanDex::index(store_path, file, force)
        if !content.nil?
            file = File.expand_path(file)
            ScanDex::store_document(store_path, file, content)
        end
    end

    def self.index(store_path, source, force = false)
        accepted_formats = ['.pdf', '.png', '.jpg', '.jpeg', '.tiff']
        if (force || !self.has_document(store_path, source)) && accepted_formats.include?(File.extname(source).downcase)
            puts "Indexing #{source}"
            tmp = Dir.mktmpdir('scandex_')
            pages = convert_to_gray_scale(source, tmp)
            puts "Found #{pages.size} page(s)"
            if pages.size > 0
                ocr(pages)
            else
                nil
            end
        else
            puts "Ignoring '#{source}'"
            nil
        end
    end

    def self.convert_to_gray_scale(source, destination)
        cmd = "#{self.convert} -density 300 -depth 8 -type grayscale \"#{source}\" #{destination}/convert-%04d.jpg"
        #puts "cmd = #{cmd}"
        puts "Converting '#{File.basename(source)}'"
        ret = system(cmd)
        if !ret
            puts "Failed to convert #{source}"
            []
        else
            Dir["#{destination}/convert-*.jpg"]
        end
    end

    def self.ocr(pages, language = "eng")
        text = ''
        pages.each do |page|
            puts "OCR on '#{File.basename(page)}'"
            text += image_to_string(page, language)
        end
        text
    end

    # TODO orientation and language detection
    def self.image_to_string(image, language = "eng")
        img = RTesseract.new(image, :lang => language)
        img.to_s
    end

    def self.db(store_path)
        store_path = '~/' if store_path.nil? || store_path.empty?
        filename = File.expand_path("#{store_path}/.scandex.db")
        migrate = !File.exists?(filename)
        db = SQLite3::Database.new(filename)
        if migrate
            puts "Creating DB"
            db.execute("CREATE TABLE documents (name VARCHAR(255), content TEXT, created TEXT, modified TEXT)")
        end
        db
    end

    def self.has_document(store_path, name)
        db = self.db(store_path)
        rows = db.execute("SELECT name FROM documents WHERE name = ?", [name])
        rows.size > 0
    end

    def self.documents(store_path)
        db = self.db(store_path)
        db.execute("SELECT name, created, modified FROM documents")
    end

    def self.search_documents(store_path, text)
        db = self.db(store_path)
        pattern = "%#{text.downcase}%"
        db.execute("SELECT name, created, modified FROM documents WHERE LOWER(content) LIKE ? OR LOWER(name) LIKE ?", [pattern, pattern])
    end

    def self.store_document(store_path, source, content)
        created = File.mtime(source).utc.iso8601
        modified = File.ctime(source).utc.iso8601

        db = self.db(store_path)
        rows = db.execute("SELECT * FROM documents WHERE name = ?", source)
        if rows.size == 0
            puts "Insert: #{source} #{created} #{modified}"
            db.execute("INSERT INTO documents (name, content, created, modified) VALUES (?, ?, ?, ?)", [source, content, created, modified])
        else
            puts "Update: #{source} #{created} #{modified}"
            db.execute("UPDATE documents SET content = ?, modified = ? WHERE name = ?", [content, modified, source])
        end
    end
end

