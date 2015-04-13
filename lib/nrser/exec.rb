require 'nrser'

using NRSER

module NRSER::Exec
  class Result
    attr_reader :cmd, :exitstatus, :output

    def initialize cmd, exitstatus, output
      @cmd = cmd
      @exitstatus = exitstatus
      @output = output
    end

    def raise_error
      raise SystemCallError.new <<-BLOCK.unblock, @exitstatus
        cmd `#{ @cmd }` failed with status #{ @exitstatus }
        and output #{ @output.inspect }
      BLOCK
    end

    def check_error
      raise_error unless success?
    end

    def success?
      @exitstatus == 0
    end

    def failure?
      ! success?
    end
  end

  # substitute stuff into a shell command after escaping with 
  # `Shellwords.escape`.
  #
  # arguments after the first may be multiple values that will
  # be treated like a positional list for substitution, or a single
  # hash that will be treated like a key substitution.
  #
  # any substitution value that is an Array will be treated like a list of
  # path segments and joined with `File.join`.
  def self.sub command, subs
    quoted = case subs
    when Hash
      Hash[
        subs.map do |key, sub|
          sub = File.join(*sub) if sub.is_a? Array
          # shellwords in 1.9.3 can't handle symbols
          sub = sub.to_s if sub.is_a? Symbol
          [key, Shellwords.escape(sub)]
        end
      ]
    when Array
      subs.map do |sub|
        sub = File.join(*sub) if sub.is_a? Array
        # shellwords in 1.9.3 can't handle symbols
        sub = sub.to_s if sub.is_a? Symbol
        Shellwords.escape sub
      end
    else
      raise "should be Hash or Array: #{ subs.inspect }"
    end
    command % quoted
  end # ::sub

  def self.run cmd, subs = nil
    cmd = sub(cmd, subs) unless subs.nil?
    output = `#{ cmd } 2>&1`
    exitstatus = $?.exitstatus

    if exitstatus == 0
      return output
    else
      raise SystemCallError.new <<-BLOCK.unblock, exitstatus
        hey - cmd `#{ cmd }` failed with status #{ $?.exitstatus }
        and output #{ output.inspect }
      BLOCK
    end
  end # ::run

  def self.result cmd, subs = nil
    cmd = sub(cmd, subs) unless subs.nil?
    output = `#{ cmd } 2>&1`
    Result.new cmd, $?.exitstatus, output
  end # ::result
end