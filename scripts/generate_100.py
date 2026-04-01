#!/usr/bin/env python3
"""Generate 100 new SEO-optimized cannabis articles in 5 languages (500 HTML files).
Also updates articles.html and sitemap.xml."""

import json
import os
import re
import html as html_mod

BASE = "/home/user/howtoedibles"

# ── Extract nav/search/footer from existing articles ──────────────────────
def extract_section(filepath, start, end):
    with open(filepath) as f:
        lines = f.readlines()
    return ''.join(lines[start-1:end])

TEMPLATES = {}
for lang, info in {
    "en": ("/home/user/howtoedibles/cannabis-and-alcohol.html", 117, 323, 325, 330, 495, 538),
    "de": ("/home/user/howtoedibles/de/cannabis-and-alcohol.html", 52, 358, 360, 366, 537, 583),
    "es": ("/home/user/howtoedibles/es/cannabis-and-alcohol.html", 53, 359, 361, 376, 523, 569),
    "pt": ("/home/user/howtoedibles/pt/cannabis-and-alcohol.html", 53, 359, 361, 375, 522, 568),
    "zh": ("/home/user/howtoedibles/zh/cannabis-and-alcohol.html", 52, 358, 360, 375, 655, 701),
}.items():
    f, ns, ne, ss, se, fs, fe = info
    TEMPLATES[lang] = {
        "nav": extract_section(f, ns, ne),
        "search": extract_section(f, ss, se),
        "footer": extract_section(f, fs, fe),
    }

# ── Language config ───────────────────────────────────────────────────────
LANG_CFG = {
    "en": {"prefix":"","html_lang":"en","home":"/","articles":"/articles.html",
           "bc_home":"Home","bc_articles":"Articles","toc_h":"Table of Contents",
           "read_more":"Read more articles","related_h":"Related Articles","date":"March 25, 2026"},
    "de": {"prefix":"/de","html_lang":"de","home":"/de/","articles":"/de/articles.html",
           "bc_home":"Startseite","bc_articles":"Artikel","toc_h":"Inhaltsverzeichnis",
           "read_more":"Weitere Artikel lesen","related_h":"Verwandte Artikel","date":"25. März 2026"},
    "es": {"prefix":"/es","html_lang":"es","home":"/es/","articles":"/es/articles.html",
           "bc_home":"Inicio","bc_articles":"Artículos","toc_h":"Tabla de contenidos",
           "read_more":"Leer más artículos","related_h":"Artículos relacionados","date":"25 de marzo de 2026"},
    "pt": {"prefix":"/pt","html_lang":"pt-BR","home":"/pt/","articles":"/pt/articles.html",
           "bc_home":"Início","bc_articles":"Artigos","toc_h":"Índice",
           "read_more":"Leia mais artigos","related_h":"Artigos relacionados","date":"25 de março de 2026"},
    "zh": {"prefix":"/zh","html_lang":"zh-Hans","home":"/zh/","articles":"/zh/articles.html",
           "bc_home":"首页","bc_articles":"文章","toc_h":"目录",
           "read_more":"阅读更多文章","related_h":"相关文章","date":"2026年3月25日"},
}

# ── Related articles pool (existing articles to link to) ──────────────────
RELATED_POOL = [
    ("cbd-vs-thc","CBD vs THC","Understanding the key differences between CBD and THC."),
    ("cannabis-and-inflammation","Cannabis and Inflammation","How cannabis reduces inflammation."),
    ("entourage-effect","The Entourage Effect","How cannabinoids work together."),
    ("microdosing-edibles","Microdosing Edibles","A beginner's guide to microdosing."),
    ("cannabis-and-sleep","Cannabis and Sleep","Can edibles help you rest?"),
    ("how-to-prevent-a-bad-trip","Prevent a Bad Trip","Tips for avoiding bad experiences."),
    ("cannabis-terpenes-explained","Terpenes Explained","How terpenes shape your experience."),
    ("cannabis-and-anxiety","Cannabis and Anxiety","What research says about anxiety."),
    ("science-of-decarboxylation","The Science of Decarboxylation","Why you must heat cannabis."),
    ("how-long-do-edibles-take-to-kick-in","Edible Onset Times","How long edibles take to work."),
]

# ── 100 Article Definitions ──────────────────────────────────────────────
# Format: (slug, category, {lang: {t, d, k, rt, toc, body, faq}})
# body: HTML string for article content
# toc: [(id, heading), ...]
# faq: [(question, answer), ...]

ARTICLES = []

def body_html(takeaway, sections):
    """Build body HTML from takeaway + sections list of (id, heading, p1, p2)."""
    h = f'<div class="article-takeaway"><h4>Key Takeaway</h4><p>{takeaway}</p></div>\n'
    for sid, sheading, p1, p2 in sections:
        h += f'          <h2 id="{sid}" class="mt-4">{sheading}</h2>\n'
        h += f'          <p>{p1}</p>\n'
        h += f'          <p>{p2}</p>\n'
    return h

def body_html_de(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Kernaussage</h4><p>{takeaway}</p></div>\n'
    for sid, sheading, p1, p2 in sections:
        h += f'          <h2 id="{sid}" class="mt-4">{sheading}</h2>\n'
        h += f'          <p>{p1}</p>\n'
        if p2: h += f'          <p>{p2}</p>\n'
    return h

def body_html_es(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Punto clave</h4><p>{takeaway}</p></div>\n'
    for sid, sheading, p1, p2 in sections:
        h += f'          <h2 id="{sid}" class="mt-4">{sheading}</h2>\n'
        h += f'          <p>{p1}</p>\n'
        if p2: h += f'          <p>{p2}</p>\n'
    return h

def body_html_pt(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Ponto-chave</h4><p>{takeaway}</p></div>\n'
    for sid, sheading, p1, p2 in sections:
        h += f'          <h2 id="{sid}" class="mt-4">{sheading}</h2>\n'
        h += f'          <p>{p1}</p>\n'
        if p2: h += f'          <p>{p2}</p>\n'
    return h

def body_html_zh(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>关键要点</h4><p>{takeaway}</p></div>\n'
    for sid, sheading, p1, p2 in sections:
        h += f'          <h2 id="{sid}" class="mt-4">{sheading}</h2>\n'
        h += f'          <p>{p1}</p>\n'
        if p2: h += f'          <p>{p2}</p>\n'
    return h

# I'll import the article data from a separate module
import sys
sys.path.insert(0, os.path.dirname(__file__))
from articles_100_data import ARTICLES

# ── HTML Generation ───────────────────────────────────────────────────────
def generate_html(article, lang):
    cfg = LANG_CFG[lang]
    data = article[lang]
    slug = article["slug"]
    cat = article["category"]
    prefix = cfg["prefix"]
    slug_url = f"https://www.howtoedibles.com{prefix}/{slug}.html"

    tpl = TEMPLATES[lang]

    # TOC
    toc_items = "\n".join(
        f'              <li><a href="#{tid}">{th}</a></li>'
        for tid, th in data["toc"]
    )

    # Related (pick 3 from pool based on slug hash)
    h = hash(slug)
    rel_indices = [(h + i * 7) % len(RELATED_POOL) for i in range(3)]
    # Ensure unique
    seen = set()
    rel = []
    for i in rel_indices:
        if i not in seen:
            seen.add(i)
            rel.append(RELATED_POOL[i])
    while len(rel) < 3:
        for i in range(len(RELATED_POOL)):
            if i not in seen:
                seen.add(i)
                rel.append(RELATED_POOL[i])
                break

    related_cards = ""
    for rslug, rtitle, rdesc in rel:
        rhref = f"{prefix}/{rslug}.html"
        related_cards += f'''              <div class="col-md-4 mb-3">
                <div class="card h-100">
                  <div class="card-body">
                    <h5 class="card-title"><a href="{rhref}">{rtitle}</a></h5>
                    <p class="card-text">{rdesc}</p>
                  </div>
                </div>
              </div>
'''

    # FAQ schema
    faq_entities = []
    for q, ans in data["faq"]:
        faq_entities.append({"@type":"Question","name":q,"acceptedAnswer":{"@type":"Answer","text":ans}})
    faq_schema = json.dumps({"@context":"https://schema.org","@type":"FAQPage","mainEntity":faq_entities}, indent=2, ensure_ascii=False)

    article_schema = json.dumps({
        "@context":"https://schema.org","@type":"Article",
        "headline": data["t"],"description": data["d"],
        "datePublished":"2026-03-25","dateModified":"2026-03-25",
        "author":{"@type":"Organization","name":"HowToEdibles"},
        "publisher":{"@type":"Organization","name":"HowToEdibles"}
    }, indent=4, ensure_ascii=False)

    bc_schema = json.dumps({
        "@context":"https://schema.org","@type":"BreadcrumbList",
        "itemListElement":[
            {"@type":"ListItem","position":1,"name":cfg["bc_home"],"item":f"https://www.howtoedibles.com{prefix}/"},
            {"@type":"ListItem","position":2,"name":cfg["bc_articles"],"item":f"https://www.howtoedibles.com{prefix}/articles.html"},
            {"@type":"ListItem","position":3,"name":data["t"]}
        ]
    }, indent=4, ensure_ascii=False)

    hreflangs = f"""  <link rel="alternate" hreflang="en" href="https://www.howtoedibles.com/{slug}.html" />
  <link rel="alternate" hreflang="pt-BR" href="https://www.howtoedibles.com/pt/{slug}.html" />
  <link rel="alternate" hreflang="es" href="https://www.howtoedibles.com/es/{slug}.html" />
  <link rel="alternate" hreflang="de" href="https://www.howtoedibles.com/de/{slug}.html" />
  <link rel="alternate" hreflang="zh-Hans" href="https://www.howtoedibles.com/zh/{slug}.html" />
  <link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/{slug}.html" />"""

    return f'''<!DOCTYPE html>
<html lang="{cfg["html_lang"]}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <title>{html_mod.escape(data["t"])} | HowToEdibles</title>
  <meta name="description" content="{html_mod.escape(data["d"])}" />
  <meta name="keywords" content="{html_mod.escape(data["k"])}" />
  <link rel="canonical" href="{slug_url}" />
  <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />
  <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

  <!-- hreflang -->
{hreflangs}

  <meta property="og:type" content="article" />
  <meta property="og:site_name" content="HowToEdibles" />
  <meta property="og:title" content="{html_mod.escape(data["t"])}" />
  <meta property="og:description" content="{html_mod.escape(data["d"])}" />
  <meta property="og:url" content="{slug_url}" />

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{html_mod.escape(data["t"])}" />
  <meta name="twitter:description" content="{html_mod.escape(data["d"])}" />
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
  {bc_schema}
  </script>

  <script type="application/ld+json">
  {faq_schema}
  </script>
</head>
<body>
  {tpl["nav"]}
{tpl["search"]}
  <section class="article-hero"><div class="container"><span class="article-category">{cat}</span><h1>{html_mod.escape(data["t"])}</h1><div class="article-meta"><span><i class="fa fa-calendar"></i> {cfg["date"]}</span><span><i class="fa fa-clock"></i> {data["rt"]}</span></div><p class="article-excerpt">{html_mod.escape(data["d"])}</p></div></section>

  <nav class="article-breadcrumbs" aria-label="Breadcrumb">
    <div class="container">
      <a href="{cfg["home"]}">{cfg["bc_home"]}</a> &rsaquo; <a href="{cfg["articles"]}">{cfg["bc_articles"]}</a> &rsaquo; <span>{html_mod.escape(data["t"])}</span>
    </div>
  </nav>

  <article class="article-body">
    <div class="container">
      <div class="row">
        <div class="col-lg-8 offset-lg-2">

          <!-- Table of Contents -->
          <div class="article-toc">
            <h4>{cfg["toc_h"]}</h4>
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
            <h3>{cfg["related_h"]}</h3>
            <div class="row">
{related_cards}
            </div>
          </div>

        </div>
      </div>
    </div>
  </article>

  {tpl["footer"]}

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

# ── Update articles.html ──────────────────────────────────────────────────
def update_articles_html():
    READ_MORE_LABELS = {"en":"Read article","de":"Artikel lesen","es":"Leer artículo","pt":"Ler artigo","zh":"阅读文章"}

    for lang in ["en","de","es","pt","zh"]:
        prefix = LANG_CFG[lang]["prefix"]
        filepath = f"{BASE}{prefix}/articles.html" if prefix else f"{BASE}/articles.html"
        if not os.path.exists(filepath):
            continue

        with open(filepath) as f:
            content = f.read()

        if ARTICLES[0]["slug"] in content:
            print(f"  Skipping {filepath} (already has new articles)")
            continue

        # Update numberOfItems
        m = re.search(r'"numberOfItems":\s*(\d+)', content)
        if m:
            old = int(m.group(1))
            content = content.replace(f'"numberOfItems": {old}', f'"numberOfItems": {old + len(ARTICLES)}')

        # Add ItemList entries
        last_item = re.search(
            r'("position": \d+,\s*"name": "[^"]*",\s*"url": "[^"]*"\s*\})\s*\]',
            content, re.DOTALL)
        if last_item:
            base_pos = int(re.search(r'"numberOfItems":\s*(\d+)', content).group(1)) - len(ARTICLES)
            new_items = ""
            for i, art in enumerate(ARTICLES):
                pos = base_pos + i + 1
                url = f"https://www.howtoedibles.com{prefix + '/' if prefix else ''}{art['slug']}.html"
                title = art[lang]["t"]
                new_items += f',\n      {{"@type": "ListItem", "position": {pos}, "name": "{title}", "url": "{url}"}}'
            content = content.replace(
                last_item.group(1) + "\n    ]",
                last_item.group(1) + new_items + "\n    ]"
            )

        # Add article cards
        read_more = READ_MORE_LABELS[lang]
        new_cards = "\n      <!-- NEW BATCH 2 ARTICLES -->\n"
        for art in ARTICLES:
            href = f"/{prefix + '/' if prefix else ''}{art['slug']}.html"
            new_cards += f"""
      <a href="{href}" class="article-card">
        <span class="card-category">{art['category']}</span>
        <h2>{html_mod.escape(art[lang]['t'])}</h2>
        <p>{html_mod.escape(art[lang]['d'][:150])}</p>
        <span class="card-read-more">{read_more} <i class="fa fa-arrow-right"></i></span>
      </a>
"""

        # Insert cards before footer
        # EN pattern
        if prefix == "":
            content = content.replace(
                "\n    </div>\n  </div>\n\n  <footer",
                new_cards + "\n    </div>\n  </div>\n\n  <footer")
        else:
            # Translated files pattern
            m2 = re.search(r'(\s*</div>\s*\n\s*</div>\s*\n)(\s*<footer)', content)
            if m2:
                content = content[:m2.start(1)] + new_cards + content[m2.start(1):]

        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  Updated {filepath}")

# ── Update sitemap.xml ────────────────────────────────────────────────────
def update_sitemap():
    filepath = f"{BASE}/sitemap.xml"
    with open(filepath) as f:
        content = f.read()

    if ARTICLES[0]["slug"] in content:
        print("  Skipping sitemap (already updated)")
        return

    new_entries = ""
    for art in ARTICLES:
        s = art["slug"]
        new_entries += f"""  <url>
    <loc>https://www.howtoedibles.com/{s}.html</loc>
    <xhtml:link rel="alternate" hreflang="en" href="https://www.howtoedibles.com/{s}.html" />
    <xhtml:link rel="alternate" hreflang="pt-BR" href="https://www.howtoedibles.com/pt/{s}.html" />
    <xhtml:link rel="alternate" hreflang="es" href="https://www.howtoedibles.com/es/{s}.html" />
    <xhtml:link rel="alternate" hreflang="de" href="https://www.howtoedibles.com/de/{s}.html" />
    <xhtml:link rel="alternate" hreflang="zh-Hans" href="https://www.howtoedibles.com/zh/{s}.html" />
    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/{s}.html" />
  </url>
"""
    content = content.replace("</urlset>", new_entries + "</urlset>")
    with open(filepath, 'w') as f:
        f.write(content)
    print(f"  Updated sitemap.xml (+{len(ARTICLES)} URLs)")


# ── Main ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print(f"Generating {len(ARTICLES)} articles x 5 languages = {len(ARTICLES)*5} HTML files...")

    for i, article in enumerate(ARTICLES):
        for lang in ["en","de","es","pt","zh"]:
            prefix = LANG_CFG[lang]["prefix"]
            outdir = f"{BASE}{prefix}" if prefix else BASE
            outpath = f"{outdir}/{article['slug']}.html"
            html_content = generate_html(article, lang)
            with open(outpath, 'w') as f:
                f.write(html_content)
        if (i+1) % 10 == 0:
            print(f"  Generated {i+1}/{len(ARTICLES)} articles...")

    print(f"\nAll {len(ARTICLES)*5} HTML files generated.")

    print("\nUpdating articles.html...")
    update_articles_html()

    print("\nUpdating sitemap.xml...")
    update_sitemap()

    print("\nDone!")
