Space.delete_all

(0..31).to_a.each do |position|
  name = case position
  when 0; "The Bottoms"
  when 4; "Rebel Safehouse"
  when 8; "Barton's Forge"
  when 12; "The Stables"
  when 16; "The Trifle"
  when 20; "The Broken Pestle"
  when 24; "Temple of Pelor"
  when 28; "Market Square"
  when 31; "Sewer Entrance"
  else; ""
  end
  Space.create(name: name, position: position)
end
