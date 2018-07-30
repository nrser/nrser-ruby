def people refresh: false
  @people = nil if refresh
  @people ||= [
    { name: "Neil", fav_color: "blue", likes: [ "cat", "scotch", "computer" ] },
    { name: "Mica", fav_color: "green", likes: [ "cat", "beer", "dance" ] }
  ]
end