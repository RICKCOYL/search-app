50.times do |i|
    Article.create(
      title: Faker::Book.title,
      content: Faker::Lorem.paragraphs(number: rand(3..10)).join("\n\n")
    )
  end
  
  puts "Created #{Article.count} sample articles"