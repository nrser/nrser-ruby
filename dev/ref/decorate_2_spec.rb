# encoding: UTF-8
# frozen_string_literal: true

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Decorate,
) do
  
  shared_context "decorated: instance method" do
    
  end
  
  EACH \
    "declaration style" => [
      "comma-def",
      "name",
      "method object",
    ],
    
    "decorated" => [
      "instance method",
      "singleton method",
    ],
    
    "decorator" => [
      "class",
      "callable" => [
        "class instance",
        "proc",
        "method object",
      ],
      "unbound method object",
      "name" => [ "as String", "as Symbol" ].product(
        [ "instance method only",
          "singleton method only",
          "instance and singleton method",
          "none" ]
      )
    ]
  
end # SPEC_FILE