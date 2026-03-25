#!/usr/bin/env python3
"""Add 21 new articles to translated articles.html files."""
import re
import os

BASE = "/home/user/howtoedibles"

NEW_ARTICLES = [
    ("cannabis-and-alcohol", "Cannabis and Alcohol: Understanding the Risks of Mixing", "Health",
     "Understand the risks and effects of combining cannabis edibles with alcohol."),
    ("cannabis-and-drug-testing", "Cannabis and Drug Testing: How Long Do Edibles Stay in Your System?", "Science",
     "Everything you need to know about cannabis edibles and drug testing."),
    ("cannabis-and-exercise", "Cannabis and Exercise: How Athletes Use Edibles for Recovery", "Wellness",
     "Explore how athletes use cannabis edibles for recovery and inflammation."),
    ("cannabis-and-gut-health", "Cannabis and Gut Health: How Edibles Affect Your Digestive System", "Health",
     "Discover how cannabis edibles interact with your digestive system."),
    ("cannabis-and-immune-system", "Cannabis and the Immune System: What Science Tells Us", "Health",
     "Explore how cannabis interacts with your immune system through CB2 receptors."),
    ("cannabis-and-meditation", "Cannabis and Meditation: Enhancing Mindfulness with Low-Dose Edibles", "Wellness",
     "Discover how low-dose cannabis edibles can enhance meditation and mindfulness."),
    ("cannabis-and-pets", "Cannabis and Pets: Can CBD Help Your Dog or Cat?", "Wellness",
     "Learn about CBD for pets — benefits, dosing, THC risks, and safe products."),
    ("cannabis-and-pregnancy", "Cannabis and Pregnancy: Risks, Research, and What Doctors Say", "Health",
     "An evidence-based look at cannabis use during pregnancy and breastfeeding."),
    ("cannabis-and-ptsd", "Cannabis and PTSD: What Veterans and Trauma Survivors Should Know", "Health",
     "Explore the research on cannabis for PTSD symptoms and treatment strategies."),
    ("cannabis-dinner-party", "How to Host a Cannabis Dinner Party", "Culture",
     "Plan the perfect cannabis dinner party with dosing strategies and menu planning."),
    ("cannabis-edibles-for-beginners", "Cannabis Edibles for Beginners: Your First-Time Complete Guide", "Guides",
     "The ultimate beginner's guide to cannabis edibles, dosing, and safety tips."),
    ("cannabis-edibles-for-chronic-pain", "Cannabis Edibles for Chronic Pain: Strains, Dosing, and Science", "Health",
     "A comprehensive guide to using cannabis edibles for chronic pain management."),
    ("cannabis-for-seniors", "Cannabis for Seniors: A Complete Guide to Safe Edible Use After 60", "Health",
     "A guide to cannabis edibles for adults over 60 with safe dosing and drug interactions."),
    ("cannabis-terpenes-explained", "Cannabis Terpenes Explained: How They Shape Your Edible Experience", "Science",
     "A complete guide to cannabis terpenes and how they influence your edible experience."),
    ("cannabis-tolerance-breaks", "Cannabis Tolerance Breaks: Why, When, and How to Reset Your System", "Wellness",
     "Learn everything about cannabis tolerance breaks and how to plan a successful t-break."),
    ("cooking-with-cbd-vs-thc", "Cooking with CBD vs THC: When to Use Each in Your Kitchen", "Edibles",
     "A practical kitchen guide to cooking with CBD vs THC in your recipes."),
    ("entourage-effect", "The Entourage Effect: Why Whole-Plant Cannabis Works Better", "Science",
     "Learn how cannabinoids, terpenes, and flavonoids work together synergistically."),
    ("how-to-read-cannabis-labels", "How to Read Cannabis Edible Labels: A Consumer's Guide", "Guides",
     "Learn to decode cannabis edible labels — THC/CBD content, testing, and quality."),
    ("indica-vs-sativa-edibles", "Indica vs Sativa Edibles: Does the Strain Really Matter?", "Science",
     "Do indica and sativa distinctions matter when making edibles? Explore the science."),
    ("traveling-with-cannabis-edibles", "Traveling with Cannabis Edibles: Laws, Tips, and What to Avoid", "Guides",
     "Everything about traveling with cannabis edibles — federal vs state laws and TSA policies."),
    ("vegan-cannabis-edibles-guide", "Vegan Cannabis Edibles: A Complete Guide to Plant-Based Infusions", "Edibles",
     "Everything about making vegan cannabis edibles with plant-based infusion methods."),
]

READ_MORE = {
    "de": "Artikel lesen",
    "es": "Leer artículo",
    "pt": "Ler artigo",
    "zh": "阅读文章",
}

for lang in ["de", "es", "pt", "zh"]:
    filepath = f"{BASE}/{lang}/articles.html"
    if not os.path.exists(filepath):
        print(f"  Skipping {filepath} (not found)")
        continue

    with open(filepath) as f:
        content = f.read()

    if "cannabis-and-immune-system" in content:
        print(f"  Skipping {filepath} (already updated)")
        continue

    # Build new cards
    read_more = READ_MORE[lang]
    new_cards = "\n  <!-- NEW ARTICLES -->\n"
    for slug, title, cat, desc in NEW_ARTICLES:
        href = f"/{lang}/{slug}.html"
        new_cards += f"""
  <a href="{href}" class="article-card">
    <span class="card-category">{cat}</span>
    <h2>{title}</h2>
    <p>{desc}</p>
    <span class="card-read-more">{read_more} <i class="fa fa-arrow-right"></i></span>
  </a>
"""

    # Find the closing of articles-grid div before footer
    # Pattern: </div>\n</div>\n    <footer  OR  </div>\n</div>\n  <footer
    content = re.sub(
        r'(  </div>\n</div>\n)',
        r'\1' if '<!-- NEW ARTICLES -->' in content else new_cards + r'\1',
        content,
        count=1
    )

    # Actually let me try a different approach: insert before the footer
    # The pattern in translated files is:  </div>\n</div>\n    <footer
    # Let's just find the footer and insert before it
    if '<!-- NEW ARTICLES -->' not in content:
        # Reset and try again with footer insertion
        with open(filepath) as f:
            content = f.read()

        # Find "</div>\n</div>\n" followed by "<footer" or "    <footer"
        match = re.search(r'(\s*</div>\s*\n\s*</div>\s*\n)(\s*<footer)', content)
        if match:
            insert_point = match.start(1)
            content = content[:insert_point] + new_cards + content[insert_point:]
        else:
            print(f"  WARNING: Could not find insertion point in {filepath}")
            continue

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"  Updated {filepath} (+{len(NEW_ARTICLES)} article cards)")

print("Done!")
