# config: utf-8

User.create!(name: "管理者",
            email: "sample@email.com",
            password: "password",
            password_confirmation: "password",
            admin: true,
            basic_work_time: "2022-06-27 08:00:00",
            designed_work_start_time: "2022-06-27 09:00:00",
            designed_work_end_time: "2022-06-27 18:00:00")

User.create!(name: "上長A",
            email: "samplea@email.com",
            password: "password",
            password_confirmation: "password",
            superior: true,
            basic_work_time: "2022-06-27 08:00:00",
            designed_work_start_time: "2022-06-27 09:00:00",
            designed_work_end_time: "2022-06-27 18:00:00")            

User.create!(name: "上長B",
            email: "sampleb@email.com",
            password: "password",
            password_confirmation: "password",
            superior: true,
            basic_work_time: "2022-06-27 08:00:00",
            designed_work_start_time: "2022-06-27 09:00:00",
            designed_work_end_time: "2022-06-27 18:00:00")
            
100.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  basic_work_time = "2022-06-27 08:00:00"
  designed_work_start_time = "2022-06-27 09:00:00"
  designed_work_end_time = "2022-06-27 18:00:00"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              superior: false,
              basic_work_time: basic_work_time,
              designed_work_start_time: designed_work_start_time,
              designed_work_end_time: designed_work_end_time)
end
