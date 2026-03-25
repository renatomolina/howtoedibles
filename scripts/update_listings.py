#!/usr/bin/env python3
"""Add 21 new articles to articles.html (all languages) and sitemap.xml."""
import re
import os

BASE = "/home/user/howtoedibles"

# New articles to add (slug, title, category, description)
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
     "Learn about CBD for pets \u2014 benefits, dosing, THC risks, and safe products."),
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
     "Learn to decode cannabis edible labels \u2014 THC/CBD content, testing, and quality."),
    ("indica-vs-sativa-edibles", "Indica vs Sativa Edibles: Does the Strain Really Matter?", "Science",
     "Do indica and sativa distinctions matter when making edibles? Explore the science."),
    ("traveling-with-cannabis-edibles", "Traveling with Cannabis Edibles: Laws, Tips, and What to Avoid", "Guides",
     "Everything about traveling with cannabis edibles \u2014 federal vs state laws and TSA policies."),
    ("vegan-cannabis-edibles-guide", "Vegan Cannabis Edibles: A Complete Guide to Plant-Based Infusions", "Edibles",
     "Everything about making vegan cannabis edibles with plant-based infusion methods."),
]


def update_articles_html(lang, prefix):
    """Update articles.html for a given language."""
    if prefix:
        filepath = f"{BASE}/{prefix}/articles.html"
    else:
        filepath = f"{BASE}/articles.html"

    if not os.path.exists(filepath):
        print(f"  Skipping {filepath} (not found)")
        return

    with open(filepath) as f:
        content = f.read()

    # Check if any new article is already in the file
    if NEW_ARTICLES[0][0] in content:
        print(f"  Skipping {filepath} (already updated)")
        return

    # 1. Update numberOfItems
    old_count_match = re.search(r'"numberOfItems":\s*(\d+)', content)
    if old_count_match:
        old_count = int(old_count_match.group(1))
        new_count = old_count + len(NEW_ARTICLES)
        content = content.replace(
            f'"numberOfItems": {old_count}',
            f'"numberOfItems": {new_count}'
        )

    # 2. Add to ItemList schema (before the closing ] of itemListElement)
    # Find the last ListItem entry and add after it
    last_item_match = re.search(
        r'("position": \d+,\s*"name": "[^"]+",\s*"url": "[^"]+"\s*\})\s*\]',
        content, re.DOTALL
    )
    if last_item_match:
        last_pos = old_count if old_count_match else 29
        new_items_json = ""
        for i, (slug, title, cat, desc) in enumerate(NEW_ARTICLES):
            pos = last_pos + i + 1
            url = f"https://www.howtoedibles.com/{prefix + '/' if prefix else ''}{slug}.html"
            new_items_json += f""",
      {{
        "@type": "ListItem",
        "position": {pos},
        "name": "{title}",
        "url": "{url}"
      }}"""

        content = content.replace(
            last_item_match.group(1) + "\n    ]",
            last_item_match.group(1) + new_items_json + "\n    ]"
        )

    # 3. Add article cards before closing </div> of articles-grid
    # Find the insertion point: before the closing </div> of articles-grid
    new_cards = "\n      <!-- NEW ARTICLES -->\n"
    for slug, title, cat, desc in NEW_ARTICLES:
        href = f"/{prefix + '/' if prefix else ''}{slug}.html"
        read_more = "Read article" if not prefix else {
            "de": "Artikel lesen",
            "es": "Leer art\u00edculo",
            "pt": "Ler artigo",
            "zh": "\u9605\u8bfb\u6587\u7ae0",
        }.get(prefix, "Read article")
        new_cards += f"""
      <a href="{href}" class="article-card">
        <span class="card-category">{cat}</span>
        <h2>{title}</h2>
        <p>{desc}</p>
        <span class="card-read-more">{read_more} <i class="fa fa-arrow-right"></i></span>
      </a>
"""

    # Insert before the closing </div> of articles-grid
    content = content.replace(
        "\n    </div>\n  </div>\n\n  <footer",
        new_cards + "\n    </div>\n  </div>\n\n  <footer"
    )

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"  Updated {filepath}")


def update_sitemap():
    """Add new article URLs to sitemap.xml."""
    filepath = f"{BASE}/sitemap.xml"
    with open(filepath) as f:
        content = f.read()

    # Check if already added
    if NEW_ARTICLES[0][0] in content:
        print("  Skipping sitemap.xml (already updated)")
        return

    new_entries = ""
    for slug, title, cat, desc in NEW_ARTICLES:
        new_entries += f"""  <url>
    <loc>https://www.howtoedibles.com/{slug}.html</loc>
    <xhtml:link rel="alternate" hreflang="en" href="https://www.howtoedibles.com/{slug}.html" />
    <xhtml:link rel="alternate" hreflang="pt-BR" href="https://www.howtoedibles.com/pt/{slug}.html" />
    <xhtml:link rel="alternate" hreflang="es" href="https://www.howtoedibles.com/es/{slug}.html" />
    <xhtml:link rel="alternate" hreflang="de" href="https://www.howtoedibles.com/de/{slug}.html" />
    <xhtml:link rel="alternate" hreflang="zh-Hans" href="https://www.howtoedibles.com/zh/{slug}.html" />
    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/{slug}.html" />
  </url>
"""

    # Insert before </urlset>
    content = content.replace("</urlset>", new_entries + "</urlset>")

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"  Updated sitemap.xml (+{len(NEW_ARTICLES)} articles)")


# Update English articles.html
print("Updating English articles.html...")
update_articles_html("en", "")

# Update translated articles.html
for lang in ["de", "es", "pt", "zh"]:
    print(f"Updating {lang} articles.html...")
    update_articles_html(lang, lang)

# Update sitemap
print("Updating sitemap.xml...")
update_sitemap()

print("\nDone!")
