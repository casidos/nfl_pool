require_relative 'column'

module SequelAnnotator
  class Schema
    class << self
      def annotate_keys
        %i[name type index options]
      end

      def call(table_name, content)
        new(table_name).(content)
      end

      def header
        '# == Schema Info'
      end

      def strip_annotations(content)
        content.sub(/^#{header}.*\#\n\s+/m, '')
      end
    end

    attr_reader :db, :cols, :indexes, :raw_schema, :table_name, :uniques

    def initialize(table_name, db = SequelAnnotator.db)
      @db = db
      @table_name = table_name
      @raw_schema = db.schema(table_name)
      fetch_schema!
    end

    def annotations
      out = "#{self.class.header}\n\#\n"
      cols.each do |col|
        col_schema = col_keys.map { |k| col[k].ljust(col_sizes[k]) }
        out += "\# #{col_schema.join('  ').strip}\n"
      end
      out += "\#\n\n"
    end

    def call(content)
      content = self.class.strip_annotations(content)
      content.insert(insert_at(content), annotations)
    end

    private

    attr_reader :col_keys, :col_sizes

    def _col_sizes
      col_keys.each_with_object({}) do |k, h|
        h[k] = cols.map { |v| v[k].size }.max
      end
    end

    def _indexes(&blk)
      db.indexes(table_name).values.flat_map(&blk).compact
    end

    def insert_at(content)
      return 0 unless content[0] == '#'
      content.index("\n\n", content.index('#')) + 2
    end

    def col_sizes
      col_keys.each_with_object({}) do |k, h|
        h[k] = cols.map { |v| v[k].size }.max
      end
    end

    def fetch_cols!
      @cols = raw_schema.sort.map do |col|
        col[1][:indexed] = indexes.include?(col.first)
        col[1][:unique] = uniques.include?(col.first)
        Column.new(col).to_h
      end
    end

    def fetch_schema!
      fetch_indexes!
      fetch_uniques!
      fetch_cols!
      @col_keys = cols.first.keys
      @col_sizes = _col_sizes
    end

    def fetch_indexes!
      @indexes = _indexes { |v| v[:columns] unless v[:unique] }
    end

    def fetch_uniques!
      @uniques = _indexes do |v|
        v[:columns] if v[:unique] && v[:columns].count == 1
      end
    end
  end
end
