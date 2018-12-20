User.create!(name:  "aoki",
             email: "aoki@email.com",
             password:              "11111111",
             password_confirmation: "11111111")

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

@word = Word.new
@word.english = 'authenticated'
@word.japanese = '認証'
@word.save

@word = Word.new
@word.english = 'expires'
@word.japanese = '有効期限'
@word.save

@word = Word.new
@word.english = 'attribute'
@word.japanese = '属性'
@word.save

@word = Word.new
@word.english = 'assert'
@word.japanese = '主張する'
@word.save

@word = Word.new
@word.english = 'equal'
@word.japanese = '等しい'
@word.save
