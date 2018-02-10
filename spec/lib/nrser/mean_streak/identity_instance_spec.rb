# encoding: UTF-8
# frozen_string_literal: true

describe_spec_file(
  description: %{
    {NRSER::MeanStreak} constructed with no `#render_type` handlers
    
    Should serves as an identity function, rendering the same markdown source
    that it received.
  },
  spec_path: __FILE__,
  class: NRSER::MeanStreak,
) do
  describe_class NRSER::MeanStreak do
    describe_instance do
      describe_method :render do
        describe_called_with "hey" do
          it { is_expected.to eq "heyy" }
        end # called with "hey"
      end
    end
  end
end # describe_spec_file
