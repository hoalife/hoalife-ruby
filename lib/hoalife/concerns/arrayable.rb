# Pass a string, have it split with the given separator
module HOALife::Arrayable
  BLANK_RE = /\A[[:space:]]*\z/

  def as_array(method_name, separator: /,|\||;|\s&\s|\sand\s|\s\s+/, joiner: ",")
    define_method("#{method_name}=") do |value|
      case value
      when String
        super(value.split(separator).collect(&:strip).uniq)
      when Array
        super(
          value.reject do |sub_val|
            sub_val.nil? || sub_val.empty? || sub_val.to_s.match?(BLANK_RE)
          end.collect do |sub_val|
            case sub_val
            when String
              sub_val.split(separator).collect(&:strip)
            else
              sub_val
            end
          end.flatten.uniq
        )
      when nil
        super([])
      else
        super(value)
      end
    end
  end
end
