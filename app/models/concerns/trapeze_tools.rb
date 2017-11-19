module TrapezeTools

  #Sometimes Trapeze Sends results as an Array. Sometimes they do not.
  def arrayify object
    unless object.is_a?(Array)
      object = [object]
    end
    object
  end

end