module SequelAnnotator
  class Column
    def self.annotate_keys
      %i[name type index options]
    end

    def initialize(column)
      @column = column
    end

    def annotate_keys
      self.class.annotate_keys
    end

    def to_h
      annotate_keys.each_with_object({}) { |k, h| h[k] = send(k) }
    end

    private

    def allow_null?
      opts.fetch(:allow_null)
    end

    def default
      opts.fetch(:default)
    end

    def indexed?
      opts.fetch(:indexed)
    end

    def name
      @column.first.to_s
    end

    def index
      return 'primary_key' if primary_key?
      return 'unique' if unique?
      return 'indexed' if indexed?
      ''
    end

    def options
      options = []
      options.push('not null') unless allow_null?
      if (default_val = default)
        default_val = default_val.sub(/uuid_generate_(.*)\(\)/, 'uuid_\1')
                                 .sub(/nextval\(.*\)/, 'nextval()')
                                 .sub(/::.*?$/, '')
        options.push(default_val)
      end
      options.join(', ')
    end

    def opts
      @column.last
    end

    def primary_key?
      opts.fetch(:primary_key)
    end

    def type
      (opts.fetch(:type) || opts.fetch(:db_type)).to_s
    end

    def unique?
      opts.fetch(:unique)
    end
  end
end
