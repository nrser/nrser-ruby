require 'spec_helper'

using NRSER

truthy_strings = [
  'true', 'True', 'TRUE',
  'T', 't',
  'YES', 'yes', 'Yes',
  'Y', 'y',
  'ON', 'On', 'on',
  '1',
]

falsy_strings = [
  'false', 'False', 'FALSE',
  'F', 'f',
  'NO', 'no',
  'N', 'n',
  'OFF', 'Off', 'off',
  '0',
  '',
]

undecidable_strings = [
  'blah!',
]

describe NRSER.method(:truthy?) do
  context "strings" do
    context "true truthy strings" do
      truthy_strings.each do |string|
        it "recognizes string #{ string } as truthy" do
          expect(subject.call string).to be true
        end
      end
    end # true truthy strings
    
    context "false truthy strings" do
      truthy_strings.each do |string|
        it "recognizes string #{ string } as truthy" do
          expect(subject.call string).to be true
        end
      end
    end # false truthy strings
    
    context "undecidable truthy strings" do
      undecidable_strings.each do |string|
        it "errors on #{ string }" do
          expect{subject.call string}.to raise_error ArgumentError
        end
      end
    end # undecidable truthy strings
  end # strings
  
  context "refinement" do
    context "strings" do
      it "recognizes an empty ENV var as falsy" do
        expect(ENV['sdfaarfsg'].truthy?).to be false
      end
      
      it "recognizes nil as falsey" do
        expect(nil.truthy?).to be false
      end
      
      context "true truthy strings" do
        truthy_strings.each do |string|
          it "recognizes string #{ string } as truthy" do
            expect(string.truthy?).to be true
          end
        end
      end # true truthy strings
    end # strings
  end # refinement
  
end # NRSER.truthy?