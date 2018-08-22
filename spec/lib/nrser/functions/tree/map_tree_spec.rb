SPEC_FILE \
  spec_path: __FILE__,
  module: NRSER,
  method: :map_tree \
do
  
  SECTION "Simple Examples" do
  # ========================================================================
    
    CASE "Convert all Integers to Strings" do
      subject {
        super().call( tree ) { |element|
          if element.is_a? Integer
            element.to_s
          else
            element
          end
        }
      }

      WHEN \
        tree: {
          1 => {
            name: 'Mr. Neil',
            fav_color: 'blue',
            age: 33,
            likes: [:tacos, :cats],
          },
          
          2 => {
            name: 'Ms. Mica',
            fav_color: 'red',
            age: 32,
            likes: [:cats, :cookies],
          } } do
            it do
              is_expected.to eq \
                '1' => {
                  name: 'Mr. Neil',
                  fav_color: 'blue',
                  age: '33',
                  likes: [:tacos, :cats],
                },
                
                '2' => {
                  name: 'Ms. Mica',
                  fav_color: 'red',
                  age: '32',
                  likes: [:cats, :cookies],
                }; end; end; end; end
  
  
  SECTION "pruning" do
    CASE "Convert all Integers to Strings and prune" do
        subject do
          super().call tree, prune: true do |element|
            if element.is_a? Integer
              element.to_s
            else
              element
            end; end; end

      WHEN \
        tree: {
          1 => {
            name: 'Mr. Neil',
            fav_color?: nil,
            age: 33,
            likes: [:tacos, :cats],
          },
          
          2 => {
            name: 'Ms. Mica',
            fav_color?: 'red',
            age: 32,
            likes: [:cats, :cookies],
          },
        } \
      do  
        it do
          is_expected.to eq \
            '1' => {
              name: 'Mr. Neil',
              age: '33',
              likes: [:tacos, :cats],
            },
            
            '2' => {
              name: 'Ms. Mica',
              fav_color: 'red',
              age: '32',
              likes: [:cats, :cookies],
            }
          end; end; end; end
  
end # SPEC_FILE
