#!/usr/bin/env python3
"""Generate 50 articles in 5 languages for howtoedibles.com"""
import os, json, re

BASE = '/home/user/howtoedibles'

def extract_parts(filepath):
    with open(filepath) as f:
        content = f.read()
    nav_s = content.index('<nav class="navbar')
    nav_e = content.index('</nav>') + 6
    sb_s = content.index('<div class="site-search-bar')
    sec_m = re.search(r'<section class="article-hero"', content)
    ft_s = content.index('<footer')
    ft_e = content.index('</footer>') + 9
    bd_e = content.index('</body>')
    return content[nav_s:nav_e] + '\n\n' + content[sb_s:sec_m.start()].rstrip(), content[ft_s:ft_e], content[ft_e:bd_e].strip()

NAV, FT, SC = {}, {}, {}
for l in ['en','de','es','pt','zh']:
    p = os.path.join(BASE, 'cannabis-and-alcohol.html') if l=='en' else os.path.join(BASE, l, 'cannabis-and-alcohol.html')
    NAV[l], FT[l], SC[l] = extract_parts(p)

LB = {
    'en':{'h':'Home','a':'Articles','t':'Table of Contents','r':'Related Articles','m':'Read more articles','k':'Key Takeaway'},
    'de':{'h':'Startseite','a':'Artikel','t':'Inhaltsverzeichnis','r':'Verwandte Artikel','m':'Weitere Artikel lesen','k':'Kernaussage'},
    'es':{'h':'Inicio','a':'Artículos','t':'Tabla de contenidos','r':'Artículos relacionados','m':'Leer más artículos','k':'Punto clave'},
    'pt':{'h':'Início','a':'Artigos','t':'Índice','r':'Artigos relacionados','m':'Ler mais artigos','k':'Ponto-chave'},
    'zh':{'h':'首页','a':'文章','t':'目录','r':'相关文章','m':'阅读更多文章','k':'关键要点'},
}
HL = {'en':'en','pt':'pt-BR','es':'es','de':'de','zh':'zh-Hans'}

def ej(s): return json.dumps(s)[1:-1]
def ea(s): return s.replace('&','&amp;').replace('"','&quot;').replace('<','&lt;').replace('>','&gt;')

def gen(slug, d, lang):
    lb=LB[lang]; px=f'/{lang}' if lang!='en' else ''
    can=f'https://www.howtoedibles.com{px}/{slug}.html'
    hl='\n'.join([f'  <link rel="alternate" hreflang="{HL[x]}" href="https://www.howtoedibles.com{"/" + x if x!="en" else ""}/{slug}.html" />' for x in ['en','pt','es','de','zh']]+[f'  <link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/{slug}.html" />'])
    fqi=','.join([f'{{"@type":"Question","name":"{ej(q[0])}","acceptedAnswer":{{"@type":"Answer","text":"{ej(q[1])}"}}}}' for q in d.get('faq',[])])
    fqs=f'\n  <script type="application/ld+json">\n  {{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{fqi}]}}\n  </script>' if fqi else ''
    toc='\n'.join([f'              <li><a href="#{t[0]}">{t[1]}</a></li>' for t in d.get('toc',[])])
    rel=''
    if d.get('rel'):
        cs='\n'.join([f'              <div class="col-md-4 mb-3"><div class="card h-100"><div class="card-body"><h5 class="card-title"><a href="{px}/{r[0]}.html">{r[1]}</a></h5><p class="card-text">{r[2]}</p></div></div></div>' for r in d['rel']])
        rel=f'\n          <div class="related-articles mt-4 mb-5"><h3>{lb["r"]}</h3><div class="row">\n{cs}\n          </div></div>'
    return f'''<!DOCTYPE html>
<html lang="{lang}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <title>{d['ti']} | HowToEdibles</title>
  <meta name="description" content="{ea(d['de'])}" />
  <meta name="keywords" content="{ea(d['kw'])}" />
  <link rel="canonical" href="{can}" />
  <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />
  <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />
{hl}
  <meta property="og:type" content="article" />
  <meta property="og:site_name" content="HowToEdibles" />
  <meta property="og:title" content="{ea(d['ti'])}" />
  <meta property="og:description" content="{ea(d['de'][:200])}" />
  <meta property="og:url" content="{can}" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{ea(d['ti'])}" />
  <meta name="twitter:description" content="{ea(d['de'])}" />
  <meta name="twitter:site" content="@howtoedibles" />
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" crossorigin="anonymous" />
  <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" onload="this.rel='stylesheet'" />
  <noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /></noscript>
  <link rel="stylesheet" href="/css/styles.css" />
  <script>try{{if(localStorage.getItem("theme")==="dark")document.documentElement.setAttribute("data-theme","dark")}}catch(e){{}}</script>
  <script type="application/ld+json">
  {{"@context":"https://schema.org","@type":"Article","headline":"{ej(d['ti'])}","description":"{ej(d['de'])}","datePublished":"2026-03-24","dateModified":"2026-03-24","author":{{"@type":"Organization","name":"HowToEdibles"}},"publisher":{{"@type":"Organization","name":"HowToEdibles"}}}}
  </script>
  <script type="application/ld+json">
  {{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{{"@type":"ListItem","position":1,"name":"{lb['h']}","item":"https://www.howtoedibles.com{px}/"}},{{"@type":"ListItem","position":2,"name":"{lb['a']}","item":"https://www.howtoedibles.com{px}/articles.html"}},{{"@type":"ListItem","position":3,"name":"{ej(d['ti'])}"}}]}}
  </script>{fqs}
</head>
<body>
  {NAV[lang]}
  <section class="article-hero"><div class="container"><span class="article-category">{d['cat']}</span><h1>{d['ti']}</h1><div class="article-meta"><span><i class="fa fa-calendar"></i> March 24, 2026</span><span><i class="fa fa-clock"></i> {d['rt']}</span></div><p class="article-excerpt">{d['de']}</p></div></section>
  <nav class="article-breadcrumbs" aria-label="Breadcrumb"><div class="container"><a href="{px}/">{lb['h']}</a> &rsaquo; <a href="{px}/articles.html">{lb['a']}</a> &rsaquo; <span>{d['ti']}</span></div></nav>
  <article class="article-body"><div class="container"><div class="row"><div class="col-lg-8 offset-lg-2">
    <div class="article-toc"><h4>{lb['t']}</h4><ul>
{toc}
    </ul></div>
    {d['body']}
    <div class="text-center mt-5 mb-5"><a href="{px}/articles.html" class="btn btn-success btn-lg">{lb['m']}</a></div>
{rel}
  </div></div></div></article>
  {FT[lang]}
  {SC[lang]}
</body>
</html>'''

def write_art(slug, langs):
    for lang, d in langs.items():
        html = gen(slug, d, lang)
        path = os.path.join(BASE, f'{slug}.html') if lang=='en' else os.path.join(BASE, lang, f'{slug}.html')
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path,'w') as f: f.write(html)
    print(f'  OK: {slug}')

# Load article definitions from JSON data files
import glob
for jf in sorted(glob.glob(os.path.join(BASE, 'data', 'new_articles_*.json'))):
    with open(jf) as f:
        batch = json.load(f)
    for art in batch:
        write_art(art['slug'], art['langs'])

print("All articles generated!")
