#!/usr/bin/env python3
"""Generate cannabis-and-immune-system.html in all 5 languages from articles_50.json data."""
import json
import re
import os

BASE = "/home/user/howtoedibles"
SLUG = "cannabis-and-immune-system"

# Load article data
with open(f"{BASE}/data/articles_50.json") as f:
    articles = json.load(f)

article = articles[0]  # Only entry

# Template source files to copy nav/footer from
TEMPLATE_SOURCES = {
    "en": f"{BASE}/cannabis-and-alcohol.html",
    "de": f"{BASE}/de/cannabis-and-alcohol.html",
    "es": f"{BASE}/es/cannabis-and-alcohol.html",
    "pt": f"{BASE}/pt/cannabis-and-alcohol.html",
    "zh": f"{BASE}/zh/cannabis-and-alcohol.html",
}

LANG_CONFIG = {
    "en": {"prefix": "", "hreflang": "en", "home": "/", "articles": "/articles.html",
           "breadcrumb_home": "Home", "breadcrumb_articles": "Articles",
           "toc_title": "Table of Contents", "read_more": "Read more articles",
           "related_title": "Related Articles", "date": "March 25, 2026",
           "lang_label": "EN", "lang_active": "English",
           "search_placeholder": "Search 420+ cannabis recipes…"},
    "de": {"prefix": "/de", "hreflang": "de", "home": "/de/", "articles": "/de/articles.html",
           "breadcrumb_home": "Startseite", "breadcrumb_articles": "Artikel",
           "toc_title": "Inhaltsverzeichnis", "read_more": "Weitere Artikel lesen",
           "related_title": "Verwandte Artikel", "date": "25. März 2026",
           "lang_label": "DE", "lang_active": "Deutsch",
           "search_placeholder": "Suche 420+ Cannabis-Rezepte…"},
    "es": {"prefix": "/es", "hreflang": "es", "home": "/es/", "articles": "/es/articles.html",
           "breadcrumb_home": "Inicio", "breadcrumb_articles": "Artículos",
           "toc_title": "Tabla de contenidos", "read_more": "Leer más artículos",
           "related_title": "Artículos relacionados", "date": "25 de marzo de 2026",
           "lang_label": "ES", "lang_active": "Español",
           "search_placeholder": "Busca más de 420 recetas de cannabis…"},
    "pt": {"prefix": "/pt", "hreflang": "pt-BR", "home": "/pt/", "articles": "/pt/articles.html",
           "breadcrumb_home": "Início", "breadcrumb_articles": "Artigos",
           "toc_title": "Índice", "read_more": "Leia mais artigos",
           "related_title": "Artigos relacionados", "date": "25 de março de 2026",
           "lang_label": "PT", "lang_active": "Portugues",
           "search_placeholder": "Pesquise mais de 420 receitas de cannabis…"},
    "zh": {"prefix": "/zh", "hreflang": "zh-Hans", "home": "/zh/", "articles": "/zh/articles.html",
           "breadcrumb_home": "首页", "breadcrumb_articles": "文章",
           "toc_title": "目录", "read_more": "阅读更多文章",
           "related_title": "相关文章", "date": "2026年3月25日",
           "lang_label": "中文", "lang_active": "中文",
           "search_placeholder": "搜索420+大麻食谱…"},
}

# Related articles (same for all languages, using English titles)
RELATED = [
    ("cbd-vs-thc", "CBD vs THC", "Understanding the key differences between CBD and THC."),
    ("cannabis-and-inflammation", "Cannabis and Inflammation", "How cannabis reduces inflammation in the body."),
    ("entourage-effect", "The Entourage Effect", "How cannabinoids work together for enhanced benefits."),
]

def extract_nav_footer(filepath):
    """Extract nav and footer HTML from an existing article."""
    with open(filepath) as f:
        content = f.read()

    # Extract nav (from <nav to </nav>)
    nav_match = re.search(r'(<nav class="navbar.*?</nav>)', content, re.DOTALL)
    nav = nav_match.group(1) if nav_match else ""

    # Extract search bar
    search_match = re.search(r'(<div class="site-search-bar">.*?</div>\s*</div>)', content, re.DOTALL)
    search = search_match.group(1) if search_match else ""

    # Extract footer
    footer_match = re.search(r'(<footer.*?</footer>)', content, re.DOTALL)
    footer = footer_match.group(1) if footer_match else ""

    return nav, search, footer


def build_faq_schema(faqs):
    """Build FAQ structured data."""
    entities = []
    for q, a in faqs:
        entities.append({
            "@type": "Question",
            "name": q,
            "acceptedAnswer": {
                "@type": "Answer",
                "text": a
            }
        })
    return {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "mainEntity": entities
    }


def generate_article(lang):
    cfg = LANG_CONFIG[lang]
    data = article[lang]
    prefix = cfg["prefix"]
    slug_url = f"https://www.howtoedibles.com{prefix}/{SLUG}.html"

    nav, search, footer = extract_nav_footer(TEMPLATE_SOURCES[lang])

    # Build TOC HTML
    toc_items = "\n".join(
        f'              <li><a href="#{tid}">{ttitle}</a></li>'
        for tid, ttitle in data["toc"]
    )

    # Build related articles HTML
    related_cards = ""
    for rslug, rtitle, rdesc in RELATED:
        related_cards += f'''              <div class="col-md-4 mb-3">
                <div class="card h-100">
                  <div class="card-body">
                    <h5 class="card-title"><a href="{prefix}/{rslug}.html">{rtitle}</a></h5>
                    <p class="card-text">{rdesc}</p>
                  </div>
                </div>
              </div>
'''

    # Build FAQ schema
    faq_schema = json.dumps(build_faq_schema(data["faq"]), indent=2, ensure_ascii=False)

    # Article schema
    article_schema = json.dumps({
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": data["title"],
        "description": data["description"],
        "datePublished": "2026-03-25",
        "dateModified": "2026-03-25",
        "author": {"@type": "Organization", "name": "HowToEdibles"},
        "publisher": {"@type": "Organization", "name": "HowToEdibles"}
    }, indent=4, ensure_ascii=False)

    # Breadcrumb schema
    bc_home_url = f"https://www.howtoedibles.com{prefix}/"
    bc_articles_url = f"https://www.howtoedibles.com{prefix}/articles.html"
    breadcrumb_schema = json.dumps({
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": cfg["breadcrumb_home"], "item": bc_home_url},
            {"@type": "ListItem", "position": 2, "name": cfg["breadcrumb_articles"], "item": bc_articles_url},
            {"@type": "ListItem", "position": 3, "name": data["title"]}
        ]
    }, indent=4, ensure_ascii=False)

    # Hreflang links
    hreflangs = f'''  <link rel="alternate" hreflang="en" href="https://www.howtoedibles.com/{SLUG}.html" />
  <link rel="alternate" hreflang="pt-BR" href="https://www.howtoedibles.com/pt/{SLUG}.html" />
  <link rel="alternate" hreflang="es" href="https://www.howtoedibles.com/es/{SLUG}.html" />
  <link rel="alternate" hreflang="de" href="https://www.howtoedibles.com/de/{SLUG}.html" />
  <link rel="alternate" hreflang="zh-Hans" href="https://www.howtoedibles.com/zh/{SLUG}.html" />
  <link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/{SLUG}.html" />'''

    html_lang = "en" if lang == "en" else ("pt-BR" if lang == "pt" else ("zh-Hans" if lang == "zh" else lang))

    html = f'''<!DOCTYPE html>
<html lang="{html_lang}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <title>{data["title"]} | HowToEdibles</title>
  <meta name="description" content="{data["description"]}" />
  <meta name="keywords" content="{data["keywords"]}" />
  <link rel="canonical" href="{slug_url}" />
  <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />
  <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

  <!-- hreflang -->
{hreflangs}

  <meta property="og:type" content="article" />
  <meta property="og:site_name" content="HowToEdibles" />
  <meta property="og:title" content="{data["title"]}" />
  <meta property="og:description" content="{data["description"]}" />
  <meta property="og:url" content="{slug_url}" />

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{data["title"]}" />
  <meta name="twitter:description" content="{data["description"]}" />
  <meta name="twitter:site" content="@howtoedibles" />

  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" crossorigin="anonymous" />
  <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" onload="this.rel='stylesheet'" />
  <noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /></noscript>
  <link rel="stylesheet" href="/css/styles.css" />
  <script>try{{if(localStorage.getItem("theme")==="dark")document.documentElement.setAttribute("data-theme","dark")}}catch(e){{}}</script>

  <script type="application/ld+json">
  {article_schema}
  </script>

  <script type="application/ld+json">
  {breadcrumb_schema}
  </script>

  <script type="application/ld+json">
  {faq_schema}
  </script>
</head>
<body>
  {nav}

{search}

  <section class="article-hero"><div class="container"><span class="article-category">{article["category"]}</span><h1>{data["title"]}</h1><div class="article-meta"><span><i class="fa fa-calendar"></i> {cfg["date"]}</span><span><i class="fa fa-clock"></i> 7 min read</span></div><p class="article-excerpt">{data["description"]}</p></div></section>

  <nav class="article-breadcrumbs" aria-label="Breadcrumb">
    <div class="container">
      <a href="{cfg["home"]}">{cfg["breadcrumb_home"]}</a> &rsaquo; <a href="{cfg["articles"]}">{cfg["breadcrumb_articles"]}</a> &rsaquo; <span>{data["title"]}</span>
    </div>
  </nav>

  <article class="article-body">
    <div class="container">
      <div class="row">
        <div class="col-lg-8 offset-lg-2">

          <!-- Table of Contents -->
          <div class="article-toc">
            <h4>{cfg["toc_title"]}</h4>
            <ul>
{toc_items}
            </ul>
          </div>

          {data["body"]}

          <div class="text-center mt-5 mb-5">
            <a href="{cfg["articles"]}" class="btn btn-success btn-lg">{cfg["read_more"]}</a>
          </div>

          <!-- Related Articles -->
          <div class="related-articles mt-4 mb-5">
            <h3>{cfg["related_title"]}</h3>
            <div class="row">
{related_cards}
            </div>
          </div>

        </div>
      </div>
    </div>
  </article>

  {footer}

  <!-- Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-90858722-1"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){{dataLayer.push(arguments);}}
    gtag('js', new Date());
    gtag('config', 'UA-90858722-1');
  </script>

  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <script src="/js/mobile-menu.js"></script>
  <script src="/js/homepage.js"></script>
    <script src="/js/dark-mode.js"></script>
  </body>
</html>'''

    return html


# Generate all 5 language versions
for lang in ["en", "de", "es", "pt", "zh"]:
    html = generate_article(lang)
    prefix = LANG_CONFIG[lang]["prefix"]
    if prefix:
        outdir = f"{BASE}{prefix}"
    else:
        outdir = BASE
    outpath = f"{outdir}/{SLUG}.html"
    with open(outpath, "w") as f:
        f.write(html)
    print(f"Generated {outpath}")

print("Done!")
