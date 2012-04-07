class Hash
  def reject_empty_values
    reject { |k, v| v.respond_to?(:empty?) ? v.empty? : !v }
  end
end