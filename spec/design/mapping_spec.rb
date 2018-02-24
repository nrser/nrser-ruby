# describe_spec_file(
#   spec_path: __FILE__,
#   description: %{
#     Attempting cohesive design for mapping enums and hashes, mostly to hashes
#   }
# ) do
# 
#   def as_keys enum, &block
#     if block.nil?
# 
#     else
#       enum.each do |entry|
#         yield [entry, nil]
#       end
#     end
#   end
# 
#   describe "from Enumerable" do
#     describe "|entry| => { entry => MAP(entry) }" do
#       # Should "work" even if enum is hash-like
#       enum.as_keys.map_values { |key| key.attr }
# 
#       # Will work unless enum is hash-like
#       enum.map_values { |key| key.attr }
#     end
# 
#     describe "|entry, nil| => { entry => MAP(key, nil) }" do
#       enum.as_keys.map_values { |key, _| key.attr }
#     end
#   end
# 
#   describe "from Hash" do
#     describe "|key| => { key => MAP(key) }" do
#       enum.map_values { |key| key.attr }
#     end
# 
#     describe "|key, value| => { key => MAP(key, value) }" do
#       enum.map_values { |key, _| entry.attr }
#     end
#   end
# 
# end # spec file
