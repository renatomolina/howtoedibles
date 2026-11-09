// PROTOTYPE: the final NEW UI strings for the redesign, all 5 languages, one entry per key.
// Keys are `group.key` → nest as i18n/{lang}.json → "ui": { group: { key: … } } (dot = nesting).
// Placeholders: {name}; {name|lower} lowercases (en/pt/es only — de nouns keep their capital).
// Strings that already exist in i18n/{lang}.json are NOT repeated here (see REUSED at the bottom).
// Every prototype on this branch builds its T table from this file, so the fit check runs on exactly this copy.
window.STR = {
  // ---------- shell: masthead, compact bar, menu, footer ----------
  "shell.search_pill": { en: "Search {n} recipes", pt: "Buscar {n} receitas", es: "Buscar {n} recetas", de: "{n} Rezepte durchsuchen", zh: "搜索 {n} 道食谱" },
  "shell.search_short": { en: "Search recipes", pt: "Buscar receitas", es: "Buscar recetas", de: "Rezepte suchen", zh: "搜索食谱" },
  "shell.search": { en: "Search", pt: "Buscar", es: "Buscar", de: "Suchen", zh: "搜索" },
  "shell.menu": { en: "Menu", pt: "Menu", es: "Menú", de: "Menü", zh: "菜单" },
  "shell.close": { en: "Close", pt: "Fechar", es: "Cerrar", de: "Schließen", zh: "关闭" },
  "shell.recipes": { en: "Recipes", pt: "Receitas", es: "Recetas", de: "Rezepte", zh: "食谱" },
  "shell.all_recipes": { en: "All recipes", pt: "Todas as receitas", es: "Todas las recetas", de: "Alle Rezepte", zh: "全部食谱" },
  "shell.n_recipes": { en: "{n} recipes", pt: "{n} receitas", es: "{n} recetas", de: "{n} Rezepte", zh: "{n} 道食谱" },
  "shell.learn": { en: "Learn", pt: "Aprenda", es: "Aprende", de: "Wissen", zh: "学习" },
  "shell.learn_links": {
    en: ["Edibles for beginners", "How long edibles take", "Decarboxylation explained", "How to prevent a bad trip", "All articles"],
    pt: ["Comestíveis para iniciantes", "Quanto tempo leva pra bater", "Descarboxilação explicada", "Como evitar uma bad trip", "Todos os artigos"],
    es: ["Comestibles para principiantes", "Cuánto tardan en hacer efecto", "Descarboxilación explicada", "Cómo evitar un mal viaje", "Todos los artículos"],
    de: ["Edibles für Einsteiger", "Wann Edibles wirken", "Decarboxylierung erklärt", "Einen Bad Trip vermeiden", "Alle Artikel"],
    zh: ["新手入门", "多久起效", "脱羧原理", "如何避免不良反应", "全部文章"] },
  "shell.help": { en: "Too high? Get help now", pt: "Bateu forte? Peça ajuda", es: "¿Te pasaste? Pide ayuda", de: "Zu high? Jetzt Hilfe holen", zh: "太嗨了？立即求助" },
  "shell.more": { en: "More", pt: "Mais", es: "Más", de: "Mehr", zh: "更多" },
  "shell.more_links": { en: ["Calculator", "About", "Contact", "Support us"], pt: ["Calculadora", "Sobre", "Contato", "Apoie"], es: ["Calculadora", "Quiénes somos", "Contacto", "Apóyanos"], de: ["Rechner", "Über uns", "Kontakt", "Unterstützen"], zh: ["计算器", "关于", "联系", "支持我们"] },
  "shell.legal": { en: "For adults 21+ where cannabis is legal. Effects vary; start low, go slow.", pt: "Para maiores de 21 anos onde a cannabis é legal. Os efeitos variam; comece com pouco e vá devagar.", es: "Para mayores de 21 años donde el cannabis es legal. Los efectos varían; empieza con poco y ve despacio.", de: "Für Erwachsene ab 21, wo Cannabis legal ist. Die Wirkung variiert: niedrig anfangen, langsam steigern.", zh: "仅限大麻合法地区的 21 岁以上成年人。效果因人而异，从小剂量开始。" },
  "shell.language": { en: "Language", pt: "Idioma", es: "Idioma", de: "Sprache", zh: "语言" },
  "shell.appearance": { en: "Appearance", pt: "Aparência", es: "Apariencia", de: "Darstellung", zh: "外观" },
  "shell.modes": { en: ["Auto", "Light", "Dark"], pt: ["Auto", "Claro", "Escuro"], es: ["Auto", "Claro", "Oscuro"], de: ["Auto", "Hell", "Dunkel"], zh: ["自动", "浅色", "深色"] },
  "shell.calc_card": { en: "Dosage calculator", pt: "Calculadora de dose", es: "Calculadora de dosis", de: "Dosierungsrechner", zh: "剂量计算器" },
  "shell.calc_card_sub": { en: "Your mg per serving, from 3 numbers", pt: "Seus mg por porção com 3 números", es: "Tus mg por porción con 3 números", de: "Deine mg pro Portion aus 3 Zahlen", zh: "三个数字算出每份毫克" },
  "shell.browse": { en: "Browse by category", pt: "Navegue por categoria", es: "Explora por categoría", de: "Nach Kategorie", zh: "按分类浏览" },

  // ---------- search dialog ----------
  "search.cancel": { en: "Cancel", pt: "Cancelar", es: "Cancelar", de: "Abbrechen", zh: "取消" },
  "search.clear": { en: "Clear", pt: "Limpar", es: "Borrar", de: "Löschen", zh: "清除" },
  "search.popular": { en: "Most made", pt: "Mais feitas", es: "Las más hechas", de: "Am häufigsten gemacht", zh: "最多人做" },
  "search.none": { en: "No recipe for “{q}”", pt: "Nenhuma receita para “{q}”", es: "Ninguna receta para “{q}”", de: "Kein Rezept für „{q}“", zh: "没有找到“{q}”" },
  "search.none_hint": { en: "Try a simpler word, like “cookies” or “butter”.", pt: "Tente uma palavra mais simples, como “cookies” ou “manteiga”.", es: "Prueba una palabra más simple, como “galletas” o “mantequilla”.", de: "Versuch ein einfacheres Wort, etwa „Kekse“ oder „Butter“.", zh: "试试更简单的词，比如“饼干”或“黄油”。" },
  "search.see_all": { en: "See all {n} results", pt: "Ver os {n} resultados", es: "Ver los {n} resultados", de: "Alle {n} Ergebnisse", zh: "查看全部 {n} 个结果" },
  "search.also": { en: "also", pt: "também", es: "también", de: "auch", zh: "又名" },

  // ---------- ad slots ----------
  "ad.label": { en: "Advertisements", pt: "Publicidade", es: "Publicidad", de: "Anzeige", zh: "广告" },

  // ---------- calculator component (recipe pages, homepage hero, calculator page) ----------
  "calc.mg": { en: "mg", pt: "mg", es: "mg", de: "mg", zh: "毫克" },
  "calc.per": { en: "per serving", pt: "por porção", es: "por porción", de: "pro Portion", zh: "每份" },
  "calc.batch": { en: "Whole batch", pt: "Receita toda", es: "Receta entera", de: "Ganzes Rezept", zh: "整份" },
  "calc.in_batch": { en: "{mg} mg in total", pt: "{mg} mg no total", es: "{mg} mg en total", de: "{mg} mg gesamt", zh: "共 {mg} 毫克" },
  "calc.g": { en: "g", pt: "g", es: "g", de: "g", zh: "克" },
  "calc.thc": { en: "THC", pt: "THC", es: "THC", de: "THC", zh: "THC" },
  "calc.serving": { en: "serving", pt: "porção", es: "porción", de: "Portion", zh: "份" },
  "calc.servings": { en: "servings", pt: "porções", es: "porciones", de: "Portionen", zh: "份" },
  "calc.oz": { en: ["⅛ oz", "¼ oz", "½ oz", "1 oz"], pt: ["⅛ oz", "¼ oz", "½ oz", "1 oz"], es: ["⅛ oz", "¼ oz", "½ oz", "1 oz"], de: ["⅛ oz", "¼ oz", "½ oz", "1 oz"], zh: ["⅛ 盎司", "¼ 盎司", "½ 盎司", "1 盎司"] },
  "calc.average": { en: "average", pt: "média", es: "promedio", de: "mittel", zh: "平均" },
  "calc.this_recipe": { en: "This recipe", pt: "Esta receita", es: "Esta receta", de: "Dieses Rezept", zh: "本食谱" },
  "calc.your_dose": { en: "Your dose", pt: "Sua dose", es: "Tu dosis", de: "Deine Dosis", zh: "你的剂量" },
  "calc.hint": { en: "Match these to your cannabis before you start cooking.", pt: "Ajuste para a sua cannabis antes de começar.", es: "Ajústalos a tu cannabis antes de empezar a cocinar.", de: "Passe die Werte an dein Cannabis an, bevor du loslegst.", zh: "开始做之前，按你的大麻填写这三项。" },
  "calc.reset_recipe": { en: "Reset to this recipe", pt: "Voltar ao da receita", es: "Volver a esta receta", de: "Auf Rezeptwerte zurücksetzen", zh: "恢复食谱默认值" },
  "calc.reset": { en: "Reset", pt: "Redefinir", es: "Restablecer", de: "Zurücksetzen", zh: "恢复" },
  "calc.beginner": { en: "New to edibles? Start with 2.5–5 mg and wait 2 hours before having more.", pt: "Primeira vez? Comece com 2,5–5 mg e espere 2 horas antes de comer mais.", es: "¿Primera vez? Empieza con 2,5–5 mg y espera 2 horas antes de comer más.", de: "Neu bei Edibles? Fang mit 2,5–5 mg an und warte 2 Stunden, bevor du nachlegst.", zh: "第一次吃？从 2.5–5 毫克开始，至少等 2 小时再吃更多。" },
  "calc.beginner_link": { en: "Beginner's guide", pt: "Guia para iniciantes", es: "Guía para principiantes", de: "Einsteiger-Guide", zh: "新手指南" },
  "calc.split": { en: "For {t} mg, eat <b>{f}</b> of a serving", pt: "Para {t} mg, coma <b>{f}</b> de uma porção", es: "Para {t} mg, come <b>{f}</b> de una porción", de: "Für {t} mg iss <b>{f}</b> einer Portion", zh: "想要 {t} 毫克，吃一份的 <b>{f}</b>" },
  "calc.cut": { en: "or cut the batch into {n} servings", pt: "ou divida a receita em {n} porções", es: "o divide la receta en {n} porciones", de: "oder teile das Rezept in {n} Portionen", zh: "或者把整份分成 {n} 份" },
  "calc.too_strong": { en: "Too strong to split by eye. Use less cannabis or make more servings.", pt: "Forte demais para dividir no olho. Use menos cannabis ou faça mais porções.", es: "Demasiado fuerte para dividir a ojo. Usa menos cannabis o haz más porciones.", de: "Zu stark, um nach Augenmaß zu teilen. Nimm weniger Cannabis oder mach mehr Portionen.", zh: "太强了，无法凭肉眼分切。请减少大麻用量或分成更多份。" },
  "calc.full": { en: "Full calculator", pt: "Calculadora completa", es: "Calculadora completa", de: "Ganzer Rechner", zh: "完整计算器" },
  "calc.guide": { en: "Potency guide", pt: "Guia de potência", es: "Guía de potencia", de: "Potenz-Leitfaden", zh: "效力参考" },

  // ---------- recipe page ----------
  "recipe.total": { en: "Total time", pt: "Tempo total", es: "Tiempo total", de: "Gesamtzeit", zh: "总时长" },
  "recipe.makes": { en: "Makes", pt: "Rende", es: "Rinde", de: "Ergibt", zh: "份量" },
  "recipe.min": { en: "min", pt: "min", es: "min", de: "Min.", zh: "分钟" },
  "recipe.h": { en: "h", pt: "h", es: "h", de: "Std.", zh: "小时" },
  "recipe.newbie": { en: "First time? Eat <mark>{f} of a serving (≈{mg} mg)</mark> and wait 2 hours before more.", pt: "Primeira vez? Coma <mark>{f} de porção (≈{mg} mg)</mark> e espere 2 horas antes de comer mais.", es: "¿Primera vez? Come <mark>{f} de porción (≈{mg} mg)</mark> y espera 2 horas antes de comer más.", de: "Zum ersten Mal? Iss <mark>{f} Portion (≈{mg} mg)</mark> und warte 2 Stunden, bevor du mehr nimmst.", zh: "第一次？先吃<mark>{f} 份（约 {mg} 毫克）</mark>，等 2 小时再决定是否加量。" },
  "recipe.newbie_one": { en: "First time? <mark>One serving</mark> is a gentle start. Wait 2 hours before more.", pt: "Primeira vez? <mark>Uma porção</mark> é um começo leve. Espere 2 horas antes de comer mais.", es: "¿Primera vez? <mark>Una porción</mark> es un comienzo suave. Espera 2 horas antes de comer más.", de: "Zum ersten Mal? <mark>Eine Portion</mark> ist ein sanfter Einstieg. Warte 2 Stunden, bevor du mehr nimmst.", zh: "第一次？<mark>一份</mark>就是温和的开始。等 2 小时再决定是否加量。" },
  "recipe.newbie_too_strong": { en: "First time? <mark>This is too strong to split by eye.</mark> Use less cannabis or cut more servings.", pt: "Primeira vez? <mark>Forte demais para dividir no olho.</mark> Use menos cannabis ou corte mais porções.", es: "¿Primera vez? <mark>Es demasiado fuerte para dividir a ojo.</mark> Usa menos cannabis o corta más porciones.", de: "Zum ersten Mal? <mark>Zu stark, um nach Augenmaß zu teilen.</mark> Nimm weniger Cannabis oder schneide mehr Portionen.", zh: "第一次？<mark>太强了，无法凭肉眼分切。</mark>请减少大麻用量或切成更多份。" },
  "recipe.jump": { en: "Go to recipe", pt: "Ver receita", es: "Ver receta", de: "Zum Rezept", zh: "直接看做法" },
  "recipe.adjust": { en: "Adjust dose", pt: "Ajustar dose", es: "Ajustar dosis", de: "Dosis anpassen", zh: "调整剂量" },
  "recipe.adjust_sub": { en: "{g} g · {p}% THC", pt: "{g} g · {p}% THC", es: "{g} g · {p}% THC", de: "{g} g · {p} % THC", zh: "{g} 克 · {p}% THC" },
  "recipe.tap": { en: "Tap each one off as you go.", pt: "Toque em cada um conforme for fazendo.", es: "Toca cada uno a medida que avanzas.", de: "Tippe jeden Schritt ab, wenn er erledigt ist.", zh: "做完一项就点一下。" },
  "recipe.wake": { en: "Keep screen on", pt: "Tela sempre ligada", es: "Pantalla siempre encendida", de: "Bildschirm anlassen", zh: "屏幕常亮" },
  "recipe.wake_on": { en: "Screen stays on", pt: "Tela fica ligada", es: "La pantalla queda encendida", de: "Bildschirm bleibt an", zh: "屏幕保持常亮" },
  "recipe.wake_no": { en: "Your browser can't keep the screen on.", pt: "Seu navegador não mantém a tela ligada.", es: "Tu navegador no puede mantener la pantalla encendida.", de: "Dein Browser kann den Bildschirm nicht anlassen.", zh: "你的浏览器无法保持屏幕常亮。" },
  "recipe.tips": { en: "Dosing tips", pt: "Dicas de dosagem", es: "Consejos de dosis", de: "Dosierungstipps", zh: "剂量提示" },
  "recipe.questions": { en: "Questions", pt: "Perguntas", es: "Preguntas", de: "Fragen", zh: "常见问题" },
  "recipe.related": { en: "More {c|lower}", pt: "Mais {c|lower}", es: "Más {c|lower}", de: "Mehr {c}", zh: "更多{c}" },
  "recipe.make_first": { en: "Make it first →", pt: "Faça antes →", es: "Hazla primero →", de: "Zuerst machen →", zh: "先做这个 →" },

  // ---------- homepage, category pages, ?q= results ----------
  "home.all_n": { en: "All {n}", pt: "Todas ({n})", es: "Todas ({n})", de: "Alle {n}", zh: "全部 {n}" },
  "home.see_all": { en: "See all", pt: "Ver todas", es: "Ver todas", de: "Alle ansehen", zh: "查看全部" },
  "home.hero_q": { en: "How strong will it be?", pt: "Qual vai ser a potência?", es: "¿Qué tan fuerte va a quedar?", de: "Wie stark wird es?", zh: "会有多强？" },
  "home.or": { en: "or find a recipe", pt: "ou encontre uma receita", es: "o encuentra una receta", de: "oder ein Rezept finden", zh: "或者找一道食谱" },
  "home.base": { en: "Start with a base", pt: "Comece pela base", es: "Empieza por la base", de: "Erst die Basis", zh: "先做基础" },
  "home.base_sub": { en: "Most recipes need one of these first.", pt: "Quase toda receita usa uma destas antes.", es: "Casi todas las recetas necesitan una de estas primero.", de: "Die meisten Rezepte brauchen zuerst eine davon.", zh: "大多数食谱都要先做其中一种。" },
  "home.learn": { en: "Learn the basics", pt: "Aprenda o básico", es: "Aprende lo básico", de: "Die Grundlagen", zh: "基础知识" },
  "home.support": { en: '<b>Enjoying the recipes?</b> This site is free — <a href="#">support us</a>.', pt: '<b>Curtindo as receitas?</b> Este site é gratuito — <a href="#">apoie-nos</a>.', es: '<b>¿Te gustan las recetas?</b> Este sitio es gratis — <a href="#">apóyanos</a>.', de: '<b>Gefallen dir die Rezepte?</b> Diese Seite ist kostenlos — <a href="#">unterstütze uns</a>.', zh: '<b>喜欢这些食谱吗？</b>本站免费——<a href="#">支持我们</a>。' },
  "home.band_calc": { en: "Your cannabis is different?", pt: "Sua cannabis é diferente?", es: "¿Tu cannabis es diferente?", de: "Dein Cannabis ist anders?", zh: "你的大麻不一样？" },
  "home.band_calc_sub": { en: "Fit any recipe to your grams and % THC.", pt: "Ajuste qualquer receita aos seus gramas e % de THC.", es: "Ajusta cualquier receta a tus gramos y % de THC.", de: "Passe jedes Rezept an deine Gramm und % THC an.", zh: "按你的克数和 THC % 调整任何食谱。" },
  "home.cat_lede": { en: "{n} recipes, each with its THC per serving worked out.", pt: "{n} receitas, cada uma com o THC por porção já calculado.", es: "{n} recetas, cada una con su THC por porción ya calculado.", de: "{n} Rezepte, jedes mit berechnetem THC pro Portion.", zh: "{n} 道食谱，每份 THC 都已算好。" },
  "home.q_title": { en: "Results for “{q}”", pt: "Resultados para “{q}”", es: "Resultados para “{q}”", de: "Ergebnisse für „{q}“", zh: "“{q}”的结果" },
  "home.q_n": { en: "{n} recipes match", pt: "{n} receitas encontradas", es: "{n} recetas encontradas", de: "{n} passende Rezepte", zh: "找到 {n} 道食谱" },
  "home.q_none": { en: "No recipe for “{q}”. Try a simpler word, or browse a category:", pt: "Nenhuma receita para “{q}”. Tente uma palavra mais simples ou veja uma categoria:", es: "Ninguna receta para “{q}”. Prueba una palabra más simple o explora una categoría:", de: "Kein Rezept für „{q}“. Versuch ein einfacheres Wort oder eine Kategorie:", zh: "没有“{q}”的食谱。换个简单的词，或者看看分类：" },

  // ---------- calculator page ----------
  "calcpage.eyebrow": { en: "Free · no sign-up", pt: "Grátis · sem cadastro", es: "Gratis · sin registro", de: "Kostenlos · ohne Anmeldung", zh: "免费 · 无需注册" },
  "calcpage.updated": { en: "Updated {date}", pt: "Atualizada em {date}", es: "Actualizada en {date}", de: "Aktualisiert im {date}", zh: "{date}更新" },
  "calcpage.guide_sub": { en: "Where your number lands. The highlighted row follows the calculator.", pt: "Onde o seu número cai. A linha destacada acompanha a calculadora.", es: "Dónde cae tu número. La fila resaltada sigue a la calculadora.", de: "Wo dein Wert liegt. Die markierte Zeile folgt dem Rechner.", zh: "你的数值落在哪一档。高亮的一行随计算器变化。" },
  "calcpage.you": { en: "you", pt: "você", es: "tú", de: "du", zh: "你" },
  "calcpage.fx_title": { en: "The formula", pt: "A fórmula", es: "La fórmula", de: "Die Formel", zh: "公式" },
  "calcpage.fx_sub": { en: "Every recipe and this calculator use the same one.", pt: "Todas as receitas e esta calculadora usam a mesma.", es: "Todas las recetas y esta calculadora usan la misma.", de: "Alle Rezepte und dieser Rechner nutzen dieselbe.", zh: "所有食谱和这个计算器用的都是同一个公式。" },
  "calcpage.fx_g": { en: "grams of cannabis", pt: "gramas de cannabis", es: "gramos de cannabis", de: "Gramm Cannabis", zh: "大麻克数" },
  "calcpage.fx_s": { en: "THC % on the label", pt: "% de THC no rótulo", es: "% de THC en la etiqueta", de: "THC-% laut Etikett", zh: "标签上的 THC %" },
  "calcpage.fx_e": { en: "kept after decarb + infusion (~20% is lost)", pt: "o que sobra após descarboxilar e infundir (~20% se perde)", es: "lo que queda tras descarboxilar e infusionar (~20% se pierde)", de: "bleibt nach Decarb + Infusion (~20 % gehen verloren)", zh: "脱羧和浸制后的保留率（约损失 20%）" },
  "calcpage.fx_n": { en: "servings", pt: "porções", es: "porciones", de: "Portionen", zh: "份数" },
  "calcpage.fx_p": { en: "mg THC per serving", pt: "mg de THC por porção", es: "mg de THC por porción", de: "mg THC pro Portion", zh: "每份 THC 毫克数" },
  "calcpage.ex_title": { en: "Worked example", pt: "Exemplo", es: "Ejemplo", de: "Rechenbeispiel", zh: "计算示例" },
  "calcpage.ex": { en: "3.5 g at 20% THC, cut into 20 servings", pt: "3,5 g com 20% de THC, em 20 porções", es: "3,5 g con 20% de THC, en 20 porciones", de: "3,5 g mit 20 % THC, in 20 Portionen", zh: "3.5 克、20% THC，分成 20 份" },
  "calcpage.ex_yours": { en: "With your numbers", pt: "Com os seus números", es: "Con tus números", de: "Mit deinen Werten", zh: "用你的数值" },

  // ---------- articles index + article "what comes next" ----------
  "articles.h1": { en: "Cannabis articles & guides", pt: "Artigos e guias sobre cannabis", es: "Artículos y guías sobre cannabis", de: "Cannabis-Artikel & Ratgeber", zh: "大麻文章与指南" },
  "articles.deck": { en: "Dosing, safety, science and the law, checked against primary sources.", pt: "Dosagem, segurança, ciência e leis, checados em fontes primárias.", es: "Dosis, seguridad, ciencia y leyes, verificadas con fuentes primarias.", de: "Dosierung, Sicherheit, Wissenschaft und Recht, geprüft an Primärquellen.", zh: "剂量、安全、科学与法律，均以一手资料核实。" },
  "articles.search": { en: "Search articles", pt: "Buscar artigos", es: "Buscar artículos", de: "Artikel durchsuchen", zh: "搜索文章" },
  "articles.all": { en: "All", pt: "Todos", es: "Todos", de: "Alle", zh: "全部" },
  "articles.n": { en: "{n} articles", pt: "{n} artigos", es: "{n} artículos", de: "{n} Artikel", zh: "{n} 篇文章" },
  "articles.start": { en: "Start here", pt: "Comece por aqui", es: "Empieza aquí", de: "Hier anfangen", zh: "从这里开始" },
  "articles.see_all": { en: "See all {n}", pt: "Ver todos os {n}", es: "Ver los {n}", de: "Alle {n} zeigen", zh: "查看全部 {n} 篇" },
  "articles.none": { en: "No article matches that. Try a simpler word.", pt: "Nenhum artigo encontrado. Tente uma palavra mais simples.", es: "Ningún artículo coincide. Prueba una palabra más simple.", de: "Kein Artikel gefunden. Versuch ein einfacheres Wort.", zh: "没有找到相关文章。试试更简单的词。" },
  "article.next_q": { en: "How strong will yours be?", pt: "Qual vai ser a força da sua?", es: "¿Qué tan fuerte te va a quedar?", de: "Wie stark wird deins?", zh: "你做的会有多强？" },
  "article.next_sub": { en: "Work out the mg per serving before you cook.", pt: "Calcule os mg por porção antes de cozinhar.", es: "Calcula los mg por porción antes de cocinar.", de: "Rechne die mg pro Portion aus, bevor du kochst.", zh: "下厨之前，先算出每份多少毫克。" },
  "article.first_batch": { en: "Make your first batch", pt: "Faça sua primeira receita", es: "Haz tu primera receta", de: "Dein erstes Rezept", zh: "做你的第一份" },

  // ---------- 404 + donate ----------
  "e404.eyebrow": { en: "Error 404", pt: "Erro 404", es: "Error 404", de: "Fehler 404", zh: "错误 404" },
  "e404.title": { en: "This page got baked.", pt: "Essa página foi pro forno e não voltou.", es: "Esta página se quedó en el horno.", de: "Diese Seite ist im Ofen geblieben.", zh: "这个页面被烤没了。" },
  "e404.deck": { en: "The link is old, mistyped, or the page moved.", pt: "O link é antigo, foi digitado errado ou a página mudou de lugar.", es: "El enlace es viejo, está mal escrito o la página se mudó.", de: "Der Link ist alt, vertippt, oder die Seite ist umgezogen.", zh: "链接可能过期、拼写有误，或页面已经搬家。" },
  "e404.looking": { en: "Were you looking for one of these?", pt: "Você estava procurando uma destas?", es: "¿Buscabas alguna de estas?", de: "Hast du eines davon gesucht?", zh: "你是不是在找这些？" },
  "e404.popular": { en: "Most made recipes", pt: "Receitas mais feitas", es: "Las recetas más hechas", de: "Beliebteste Rezepte", zh: "最多人做的食谱" },
  "e404.search": { en: "Search recipes", pt: "Buscar receitas", es: "Buscar recetas", de: "Rezepte durchsuchen", zh: "搜索食谱" },
  "donate.mark": { en: "free", pt: "grátis", es: "gratis", de: "gratis", zh: "免费" },
  "donate.facts": { en: ["Recipes", "Guides", "Calculator"], pt: ["Receitas", "Guias", "Calculadora"], es: ["Recetas", "Guías", "Calculadora"], de: ["Rezepte", "Ratgeber", "Rechner"], zh: ["食谱", "指南", "计算器"] },
};

// Already in i18n/{lang}.json and reused as-is (not new): categories.*, calculator.weed_quantity/weed_strength/portions_question,
// calculator.potency_low/high/concentrates, calculator.dosage_* (ladder names, descriptions, table headers, guide title),
// calculator.how_to_*, try_recipe_*, faq_title, safety_note, recipe_page.ingredients/directions/common_mistakes/storage/variations/faq,
// homepage.hero_title/hero_sub, donate.*, faq.*. Contact and About stay English-only (no keys).

// T table builder for the prototypes: spec "key" → value; "key(a,b)" → template fn; "one/other(n)" → plural fn.
window.T5 = (map) => Object.fromEntries(["en", "pt", "es", "de", "zh"].map((L) => [L, Object.fromEntries(Object.entries(map).map(([k, spec]) => {
  const m = /^([\w./]+)(?:\(([\w,]*)\))?$/.exec(spec), get = (key) => { const e = STR[key]; if (!e) throw new Error("missing string " + key); return e[L]; };
  const [keys, args] = [m[1].split("/"), m[2]?.split(",")];
  const fill = (s, a) => s.replace(/\{(\w+)(\|lower)?\}/g, (_, n, low) => { const v = String(a[args.indexOf(n)]); return low ? v.toLowerCase() : v; });
  if (keys.length === 2) return [k, (n) => get(n == 1 ? keys[0] : keys[1])];
  return [k, args ? (...a) => fill(get(keys[0]), a) : get(keys[0])];
}))]));
