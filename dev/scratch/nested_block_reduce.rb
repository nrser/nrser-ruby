
def nest name, &body
  puts "at #{ name }"
  body.call
end


nest 1 do
  nest 2 do
    nest 3 do
      puts "here"
    end
  end
end

names = [1, 2, 3]

def dive name, *rest, &last
  if rest.empty?
    nest name, &last
  else
    nest name do
      dive *rest, &last
    end
  end
end

dive *names do
  puts "there"
end
