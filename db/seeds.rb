Space.delete_all

(1..40).to_a.each do |position|
  name = case position
  when 1; "The Bottoms"
  when 5; "Rebel Safehouse"
  when 10; "Barton's Forge"
  when 15; "The Stables"
  when 20; "The Trifle"
  when 25; "The Broken Pestle"
  when 25; "Market Square"
  when 30; "Temple of Pelor"
  when 35; "Guild Hall"
  when 40; "Sewer Entrance"
  else; ""
  end
  Space.create(name: name, position: position)
end
