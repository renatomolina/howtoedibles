categories = ['Desserts', 'Cooking Essentials', 'Snacks', 'Health Food']
categories.each{ |category| Category.create(name: category, slug: category.downcase.gsub!(' ','-')) }

2.times do |index|
  Recipe.create(name: 'Butter',
                slug: "butter-#{index}",
                description: 'This a very delicious recipe. You can use with as medium for any recipe.',
                ingredients: '<ul class="list-group"><li class="list-group-item">1 cup unsalted butter (2 sticks)</li><li class="list-group-item">&frac12; cup water (add more water at any time if needed)</li><li class="list-group-item"><span id="grams-quantity-recipe">7</span> ground&nbsp;weed</li></ul>',
                instructions: '<ul class="list-group"><li class="list-group-item"><strong>Before Starting: </strong>Decarb your weed - <a href="https://www.youtube.com/watch?v=MYEQaTG0WX8" target="_blank">Learn how to do</a></li><li class="list-group-item"><strong>Step 1: </strong> Add &frac12; cup of water and 2 sticks (&frac12; lb) of butter in a saucepan and bring to a simmer on low to medium heat. Adding water helps to regulate the temperature and prevents the butter from scorching. As butter begins to melt, add in ground weed.</li><li class="list-group-item"><strong>Step 2: </strong> Maintain low heat and let the mixture simmer for 2-3 hours, stirring occasionally. Make sure the mixture never comes to a full boil.</li><li class="list-group-item"><strong>Step 3: </strong> Pour the hot mixture into a glass container, using a cheesecloth to strain out all ground weed from the butter mixture. Squeeze or press the plant material to get as much liquid out of the weed as possible. Discard leftover weed.</li><li class="list-group-item"><strong>Step 4: </strong> Cover and refrigerate remaining liquid overnight or until the butter is fully hardened. Once hardened, the butter will separate from the water, allowing you to lift the cannabutter out of the container. Discard remaining water after removing the hardened cannabutter.</li><li class="list-group-item"><strong>The cannabutter in the container should have a slightly green tinge from the cannabis. Now you are ready to make some cannabis-infused meals!</strong></li></ul>',
                suggested_quantity: 7,
                suggested_portion: 48,
                video: 'https://www.youtube.com/embed/hxUbe0GeL_k',
                category: Category.find_by(name: 'Cooking Essentials'))
end

2.times do |index|
  Recipe.create(name: 'Coconut oil',
                slug: "coconut-oil-#{index}",
                description: 'This a very delicious recipe. You can use with as medium for any recipe.',
                ingredients: '<ul class="list-group"><li class="list-group-item">&frac12; cup of coconut oil</li><li class="list-group-item"><span id="grams-quantity-recipe">3.5 </span> ground weed</li></ul>',
                instructions: '<ul class="list-group"><li class="list-group-item"><strong>Before Starting: </strong>Decarb your weed - <a href="https://www.youtube.com/watch?v=MYEQaTG0WX8" target="_blank">Learn how to do</a></li><li class="list-group-item"><strong>Step 1: </strong>Add the weed to a canning jar with &frac12; cup of coconut oil.</li><li class="list-group-item"><strong>Step 2: </strong>Seal the canning jar very tightly.</li><li class="list-group-item"><strong>Step 3: </strong>Add the canning jar in boiling water using low-medium (240&deg; F - 115&deg; C) heat for over 2 hours.</li><li class="list-group-item"><strong>Step 4: </strong>Put all the jar&#39;s content into a cheesecloth over a metal strainer.</li><li class="list-group-item"><strong>Step 5: </strong>Gather the cheesecloth and squeeze all the remaining liquid out.</li></ul>',
                suggested_quantity: 3.5,
                suggested_portion: 20,
                video: 'https://www.youtube.com/embed/x5HrIKDiPH4',
                category: Category.find_by(name: 'Desserts'))
end
