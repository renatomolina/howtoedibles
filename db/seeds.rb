# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

categories = ['Deserts', 'Cooking Essentials', 'Snacks', 'Health Food']
categories.each{ |category| Category.create(name: category) }

5.times do |index|
              Recipe.create(name: 'Butter',
                            slug: "butter-#{index}",
                            description: 'This a very delicious recipe. You can use with as medium for any recipe.',
                            ingredients: '<strong>Ingredients</strong> <p>1 cup unsalted butter (2 sticks) <br /> ½ cup water (add more water at any time if needed)<br /> <span id="grams-quantity-recipe">7</span> ground weed </p>',
                            instructions: '<p> <strong>Step 1: </strong> Add ½ cup of water and 2 sticks (½ lb) of butter in a saucepan and bring to a simmer on low to medium heat. Adding water helps to regulate the temperature and prevents the butter from scorching. As butter begins to melt, add in ground weed. <br/> <strong>Step 2: </strong> Maintain low heat and let the mixture simmer for 2-3 hours, stirring occasionally. Make sure the mixture never comes to a full boil. <br /> <strong>Step 3: </strong> Pour the hot mixture into a glass container, using a cheesecloth to strain out all ground weed from the butter mixture. Squeeze or press the plant material to get as much liquid out of the weed as possible. Discard leftover weed. <br /> <strong>Step 4:</strong> Cover and refrigerate remaining liquid overnight or until the butter is fully hardened. Once hardened, the butter will separate from the water, allowing you to lift the cannabutter out of the container. Discard remaining water after removing the hardened cannabutter. <br /> <strong>The cannabutter in the container should have a slightly green tinge from the cannabis. Now you are ready to make some cannabis-infused meals!</strong> </p>',
                            suggested_weed: 7,
                            suggested_portion:48,
                            video: 'https://www.youtube.com/embed/hxUbe0GeL_k',
                            category: Category.find(2),
                            impressions_count: 0)
end

5.times do |index|
              Recipe.create(name: 'Coconut oil',
                            slug: "coconut-oil-#{index}",
                                          description: 'This a very delicious recipe. You can use with as medium for any recipe.',
                            ingredients: '<strong>Ingredients</strong> <p>1/2 cup of coconut oil <br /><span id="grams-quantity-recipe">3.5</span> ground weed </p>',
                            instructions: "<strong>Step 1: </strong>Grind your weed fine, you want to make a good surface area of exposure. <br/> <strong>Step 2: </strong>Add the grinded weed to a canning jar with 1/2 cup of coconut oil. <br/> <strong>Step 3: </strong>Seal the canning jar very tightly. <br/> <strong>Step 4: </strong>Add the canning jar in boiling water using low-medium (240 C) heat for over 2 hours. <br/> <strong>Step 5: </strong>Put all the jar's content into a cheesecloth over a metal strainer. <br/> <strong>Step 6: </strong>Gather the cheesecloth and squeese all the remaining liquid out. <br/> </p>",
                            suggested_weed: 3.5,
                            suggested_portion:20,
                            video: 'https://www.youtube.com/embed/x5HrIKDiPH4',
                            category: Category.find(2),
                            impressions_count: 0)
end
