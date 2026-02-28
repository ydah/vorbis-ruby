# frozen_string_literal: true

module Vorbis
  module Clearable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def finalizer_for(ptr, clear_state, clear_fn)
        proc { clear_fn.call(ptr) unless clear_state[0] }
      end
    end

    def setup_clearable(clear_fn)
      @clear_state = [false]
      @_native_clear = clear_fn
      ObjectSpace.define_finalizer(self, self.class.finalizer_for(@ptr, @clear_state, clear_fn))
    end

    def clear
      return if cleared?

      @_native_clear.call(@ptr)
      @clear_state[0] = true
    end

    def cleared?
      @clear_state[0]
    end
  end
end
