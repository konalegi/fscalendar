class SupportService

  class << self
    # Parsing array of time like structs
    # Example
    # parse_times(1430215454, '2015-04-28 10:00:00', Time.now, 'some invalid string')
    # => [2015-04-28 13:04:14 +0300, 2015-04-28 10:00:00 +0300, 2015-04-28 13:06:13 +0300, nil]
    def parse_times(*values)
      values.map { |value| parse_time(value) }
    end

    def parse_date(value)
      return if value.nil?
      if value.kind_of? Fixnum
        Time.at(value).to_date
      elsif value.kind_of? Time
        value.to_date
      elsif value.kind_of? Date
        value
      elsif value.kind_of? String
        if value =~ /^\d+$/
          Time.at(value.to_i).to_date
        elsif value.blank?
          return nil
        else
          Date.parse(value)
        end
      else
        return nil
      end
    end

    def parse_time(value)
      return if value.nil?

      if value.kind_of? Fixnum
        Time.at value
      elsif value.kind_of? Time
        value
      elsif value.kind_of? String
        if value =~ /^\d+$/
          Time.at(normalize_time_stamp(value.to_i))
        elsif value.blank?
          return nil
        else
          Time.parse(value)
        end
      else
        return nil
      end
    end
  end
end