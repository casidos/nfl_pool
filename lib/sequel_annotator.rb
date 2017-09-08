require 'inflecto'
require 'pathname'

ENV['RACK_ENV'] = 'development'
require_relative '../db'
require_relative 'sequel_annotator/schema'

module SequelAnnotator
  class << self
    def annotate_file!(file_name, table_name, db = self.db)
      return false unless File.exist?(file_name)
      content = File.read(file_name)
      new_content = Schema.new(table_name, db).(content)
      return false if content == new_content
      File.write(file_name, new_content)
      true
    end

    def annotate_files!(files_with_tables, db = self.db)
      files_with_tables.select { |f, t| annotate_file!(f, t, db) }.keys
    end

    def call(db: self.db)
      models_path =
        begin
          root = Pathname.new(File.expand_path('..', __FILE__)).freeze
          root.join('..', 'models')
        end
      files_with_tables = db.tables.each_with_object({}) do |table_name, h|
        h[models_path.join("#{Inflecto.singularize table_name}.rb")] = table_name
      end

      files_updated = annotate_files!(files_with_tables)
      return "No annotations necessary.\n" if files_updated.empty?
      "Files annotated:\n\n#{files_updated.join("\n")}"
    end

    def db
      DB
    end
  end
end
