# encoding: UTF-8
# frozen_string_literal: true

SPEC_FILE(
  description: %{
    {NRSER::MeanStreak} constructed with no `#render_type` handlers
    
    Should serves as an identity function, rendering the same markdown source
    that it received.
  },
  spec_path: __FILE__,
  class: NRSER::MeanStreak,
) do
  CLASS NRSER::MeanStreak do
    describe_instance do
      describe_method :render do
        describe_called_with "hey" do
          it { is_expected.to eq "hey" }
        end # called with "hey"
      end
    end
  end
end # SPEC_FILE
