# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Recipe.create(name: 'Butter',
              ingredients: '<strong>Ingredients</strong> <p>1 cup unsalted butter (2 sticks) <br /> ½ cup water (add more water at any time if needed)<br /> <span id="grams-quantity-recipe">7</span> ground weed </p>',
              instructions: '<p> <strong>1)</strong> Add ½ cup of water and 2 sticks (½ lb) of butter in a saucepan and bring to a simmer on low to medium heat. Adding water helps to regulate the temperature and prevents the butter from scorching. As butter begins to melt, add in ground weed. <br/> <strong>2)</strong> Maintain low heat and let the mixture simmer for 2-3 hours, stirring occasionally. Make sure the mixture never comes to a full boil. <br /> <strong>3)</strong> Pour the hot mixture into a glass container, using a cheesecloth to strain out all ground weed from the butter mixture. Squeeze or press the plant material to get as much liquid out of the weed as possible. Discard leftover weed. <br /> <strong>4)</strong> Cover and refrigerate remaining liquid overnight or until the butter is fully hardened. Once hardened, the butter will separate from the water, allowing you to lift the cannabutter out of the container. Discard remaining water after removing the hardened cannabutter. <br /> <strong>The cannabutter in the container should have a slightly green tinge from the cannabis. Now you are ready to make some cannabis-infused meals!</strong> </p>',
              suggested_weed:7,
              suggested_portion:48,
              video: 'https://www.youtube.com/embed/hxUbe0GeL_k')
