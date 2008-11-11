class GameController
  def initialize(parent_window)
    @parent_window = parent_window
    @action_key_bindings = Hash.new
    @action_gamepad_bindings = Hash.new
  end
  
  def method_missing(symbol, *args, &block)
    symbol_call_to_test = symbol.to_s
    if symbol_call_to_test =~ /^key_/
      action_to_assign = symbol_call_to_test.slice(4..-2).to_sym
      @action_key_bindings[action_to_assign] = args[0]
    elsif symbol_call_to_test =~ /^gamepad_/
      action_to_assign = symbol_call_to_test.slice(8..-2).to_sym
      @action_gamepad_bindings[action_to_assign] = args[0]
    elsif symbol_call_to_test =~ /_down\?/
      action_to_test = symbol_call_to_test.slice(0..-7).to_sym

      result = false
      if (@action_key_bindings.has_key?(action_to_test))
        result ||= action_pressed(@action_key_bindings[action_to_test])
      end
      
      if (@action_gamepad_bindings.has_key?(action_to_test))
        result ||= action_pressed(@action_gamepad_bindings[action_to_test])
      end

      return result
    else
      super(symbol, *args, &block)
    end
  end
  
  private
  def action_pressed(button)
    return @parent_window.button_down?(button)
  end
end