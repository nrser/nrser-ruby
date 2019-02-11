require 'nrser/ext/enumerable/find'

SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Ext::Enumerable,
  instance_method: :find_bounded!,
) do

  # TODO  Shim to adapt how spec was originally written
  subject do
    ->( enum, *args, &block ) {
      enum.n_x.find_bounded! *args, &block
    }
  end
  
  context "when just :length bounds arg is provided" do
    it "returns found elements when length is correct" do
      expect(
        subject.([1, 2, 3], length: 1) { |i| i == 2 }
      ).to eq [2]
    end
    
    it "raises TypeError when length in incorrect" do
      expect {
        subject.([1, 2, 3], length: 2) { |i| i == 2 }
      }.to raise_error TypeError
    end
  end # when just :length bounds arg is provided

  context "when just :min bounds arg is provided" do
    it "returns found elements when min is correct" do
      expect(
        subject.([1, 2, 3], min: 1) { |i| i == 2 }
      ).to eq [2]
    end
    
    it "raises TypeError when min in incorrect" do
      expect {
        subject.([1, 2, 3], min: 2) { |i| i == 2 }
      }.to raise_error TypeError
    end
  end # when just :min bounds arg is provided

  context "when just :max bounds arg is provided" do
    it "returns found elements when max is correct" do
      expect(
        subject.([1, 2, 3], max: 2) { |i| i >= 2 }
      ).to eq [2, 3]
    end
    
    it "raises TypeError when max in incorrect" do
      expect {
        subject.([1, 2, 3], max: 1) { |i| i >= 2 }
      }.to raise_error TypeError
    end
  end # when just :max bounds arg is provided


  context "when :min and :max bounds args are both provided" do
    it "returns found elements when min and max are correct" do
      expect(
        subject.([1, 2, 3], min: 1, max: 2) { |i| i >= 2 }
      ).to eq [2, 3]
    end
    
    it "raises TypeError when min is incorrect" do
      expect {
        subject.([1, 2, 3], min: 1, max: 2) { |i| false }
      }.to raise_error TypeError
    end
    
    it "raises TypeError when max is incorrect" do
      expect {
        subject.([1, 2, 3], min: 1, max: 2) { |i| true }
      }.to raise_error TypeError
    end
  end # when :min and :max bounds args are both provided

  CLASS ::Hash do
    INSTANCE a: 1, b: 2, c: 3 do
      SETUP ~%{ call `subject.n_x.find_bounded!` with `length` and `&block` } do
        subject do
          super().n_x.find_bounded! length: length, &block
        end

        WHEN length: 2 do
          WHEN 'value >= 2', block: ->((k, v)) { v >= 2 } do
            it do
              is_expected.to eq [ [:b, 2], [:c, 3] ]
            end
          end

          WHEN 'value == 2', block: ->((k, v)) { v == 2 } do
            it do expect { subject }.to raise_error TypeError end
          end
        end
      end
    end # SUBJECT
  end # CLASS

  CLASS ::Set do
    INSTANCE Set[ 1, 2, 3 ] do
      SETUP ~%{ call `subject.n_x.find_bounded` with `length` and `&block` } do

        subject do
          super().n_x.find_bounded! length: length, &block
        end

        WHEN length: 2 do
          WHEN 'value >= 2', block: ->( v ) { v >= 2 } do
            it do
              is_expected.to eq [ 2, 3 ]
            end
          end

          WHEN 'value == 2', block: ->( v ) { v == 2 } do
            it do expect { subject }.to raise_error TypeError end
          end
        end # WHEN length: 2

      end # SETUP
    end # SUBJECT
  end # CLASS Set
  
end # SPEC_FILE
