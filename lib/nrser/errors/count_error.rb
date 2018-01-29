# frozen_string_literal: true

# Raised when we expected `#count` to be something it's not.
# 
# Extends {NRSER::ValueError}, and the {#value} must be the instance that
# 
class NRSER::CountError < NRSER::AttrError
  def initialize message = nil, subject:, expected:, count: nil
    super message,
      subject: subject,
      symbol: :count,
      actual: (count || subject.count),
      expected: expected
  end
  
  def count
    actual
  end
end # class NRSER::CountError
