#!/usr/bin/env python3
"""Generate article JSON data files programmatically"""
import json, os

BASE = '/home/user/howtoedibles'

# 50 article definitions: (slug, cat_key, topic_en, topic_de, topic_es, topic_pt, topic_zh)
CATS = {
    'Health': {'en':'Health','de':'Gesundheit','es':'Salud','pt':'Saúde','zh':'健康'},
    'Edibles': {'en':'Edibles','de':'Edibles','es':'Comestibles','pt':'Comestíveis','zh':'食用品'},
    'Guides': {'en':'Guides','de':'Ratgeber','es':'Guías','pt':'Guias','zh':'指南'},
    'Wellness': {'en':'Wellness','de':'Wellness','es':'Bienestar','pt':'Bem-estar','zh':'健康生活'},
    'Culture': {'en':'Culture','de':'Kultur','es':'Cultura','pt':'Cultura','zh':'文化'},
}
RT = {'en':'7 min read','de':'7 Min. Lesezeit','es':'7 min de lectura','pt':'7 min de leitura','zh':'7分钟阅读'}
KT = {'en':'Key Takeaway','de':'Kernaussage','es':'Punto clave','pt':'Ponto-chave','zh':'关键要点'}

ARTICLES_DEF = [
  # (slug, cat, titles{lang:title}, descs{lang:desc}, kws{lang:kw}, toc_sections[(id, {lang:text})], takeaway{lang:text}, section_paras[(id, {lang:[paras]})], faqs[({lang:q},{lang:a})], rel_keys)
]

# I'll define all 50 articles with their multilingual content
# To keep it manageable, each article has:
# - Translated titles, descriptions, keywords
# - 5 TOC sections with translated headings
# - Takeaway in all languages
# - 2 paragraphs per section in all languages
# - 3 FAQ Q&A in all languages
# - 3 related articles

RELATED_POOL = [
    ('cbd-vs-thc', 'CBD vs THC', 'Understanding the differences between CBD and THC.'),
    ('cannabis-and-anxiety', 'Cannabis and Anxiety', 'How cannabis affects anxiety levels.'),
    ('cannabis-and-sleep', 'Cannabis and Sleep', 'Cannabis edibles for better sleep.'),
    ('microdosing-edibles', 'Microdosing Edibles', 'A guide to microdosing cannabis.'),
    ('cannabis-and-inflammation', 'Cannabis and Inflammation', 'How cannabis reduces inflammation.'),
    ('science-of-decarboxylation', 'Science of Decarboxylation', 'Understanding cannabis activation.'),
    ('how-long-do-edibles-take-to-kick-in', 'How Long Do Edibles Take', 'Edible onset times explained.'),
    ('entourage-effect', 'The Entourage Effect', 'Cannabinoids and terpenes together.'),
    ('how-to-store-cannabis-edibles', 'How to Store Edibles', 'Best storage practices.'),
    ('cannabis-terpenes-explained', 'Cannabis Terpenes', 'Understanding terpenes.'),
    ('how-edibles-can-help-with-pain', 'Edibles for Pain', 'Cannabis for pain management.'),
    ('edibles-vs-tinctures', 'Edibles vs Tinctures', 'Comparing methods.'),
    ('benefits-of-edibles-compared-to-smoking', 'Edibles vs Smoking', 'Why edibles are healthier.'),
    ('cannabis-and-exercise', 'Cannabis and Exercise', 'Cannabis and workouts.'),
    ('cannabis-metabolism-and-appetite', 'Cannabis and Metabolism', 'Metabolism effects.'),
    ('cannabis-for-seniors', 'Cannabis for Seniors', 'Guide for older adults.'),
]

def get_rel(indices):
    return [list(RELATED_POOL[i]) for i in indices]

def build_body(takeaway_lang, sections_lang, lang):
    """Build body HTML from takeaway and sections"""
    h = f'<div class="article-takeaway"><h4>{KT[lang]}</h4><p>{takeaway_lang}</p></div>\n'
    for sid, title, paras in sections_lang:
        h += f'          <h2 id="{sid}" class="mt-4">{title}</h2>\n'
        for p in paras:
            h += f'          <p>{p}</p>\n'
    return h

def make_article(slug, cat_key, titles, descs, kws, toc_data, takeaways, sections_data, faqs_data, rel_indices):
    """Create an article dict for all languages"""
    langs = {}
    for lang in ['en','de','es','pt','zh']:
        toc = [(s[0], s[1][lang]) for s in toc_data]
        sections = [(s[0], s[1][lang], s[2][lang]) for s in sections_data]
        body = build_body(takeaways[lang], sections, lang)
        faq = [(f[0][lang], f[1][lang]) for f in faqs_data]
        langs[lang] = {
            'ti': titles[lang],
            'de': descs[lang],
            'kw': kws[lang],
            'cat': CATS[cat_key][lang],
            'rt': RT[lang],
            'toc': toc,
            'body': body,
            'faq': faq,
            'rel': get_rel(rel_indices),
        }
    return {'slug': slug, 'langs': langs}

print("Data generator loaded OK")

# ===== ARTICLE 1: cannabis-and-immune-system =====
a1 = make_article(
    'cannabis-and-immune-system', 'Health',
    {'en':'Cannabis and the Immune System: What Science Tells Us','de':'Cannabis und das Immunsystem: Was die Wissenschaft sagt','es':'Cannabis y el sistema inmunológico: lo que dice la ciencia','pt':'Cannabis e o sistema imunológico: o que a ciência nos diz','zh':'大麻与免疫系统：科学告诉我们什么'},
    {'en':'Explore how cannabis interacts with your immune system through CB2 receptors and the endocannabinoid system. Learn about immunomodulation, autoimmune research, and what current studies reveal about cannabinoids and immune function.','de':'Erfahren Sie, wie Cannabis über CB2-Rezeptoren und das Endocannabinoid-System mit Ihrem Immunsystem interagiert. Lernen Sie über Immunmodulation und aktuelle Forschungsergebnisse zu Cannabinoiden und Immunfunktion.','es':'Descubra cómo el cannabis interactúa con su sistema inmunológico a través de los receptores CB2 y el sistema endocannabinoide. Conozca la inmunomodulación y los estudios actuales sobre cannabinoides y función inmune.','pt':'Descubra como a cannabis interage com seu sistema imunológico através dos receptores CB2 e do sistema endocanabinoide. Saiba sobre imunomodulação e pesquisas atuais sobre canabinoides e função imunológica.','zh':'探索大麻如何通过CB2受体和内源性大麻素系统与您的免疫系统互动。了解免疫调节、自身免疫研究以及当前研究对大麻素和免疫功能的发现。'},
    {'en':'cannabis immune system, CBD immunity, endocannabinoid system, CB2 receptors, cannabis immunomodulation, marijuana immune response, THC immune cells','de':'Cannabis Immunsystem, CBD Immunität, Endocannabinoid-System, CB2-Rezeptoren, Cannabis Immunmodulation, THC Immunzellen','es':'cannabis sistema inmunológico, CBD inmunidad, sistema endocannabinoide, receptores CB2, inmunomodulación cannabis, THC células inmunes','pt':'cannabis sistema imunológico, CBD imunidade, sistema endocanabinoide, receptores CB2, imunomodulação cannabis, THC células imunes','zh':'大麻免疫系统, CBD免疫力, 内源性大麻素系统, CB2受体, 大麻免疫调节, THC免疫细胞'},
    [
        ('endocannabinoid-overview', {'en':'The endocannabinoid system and immunity','de':'Das Endocannabinoid-System und Immunität','es':'El sistema endocannabinoide y la inmunidad','pt':'O sistema endocanabinoide e a imunidade','zh':'内源性大麻素系统与免疫'}),
        ('cb2-receptors', {'en':'CB2 receptors and immune cells','de':'CB2-Rezeptoren und Immunzellen','es':'Receptores CB2 y células inmunes','pt':'Receptores CB2 e células imunes','zh':'CB2受体与免疫细胞'}),
        ('immunomodulation', {'en':'Cannabis as an immunomodulator','de':'Cannabis als Immunmodulator','es':'Cannabis como inmunomodulador','pt':'Cannabis como imunomodulador','zh':'大麻作为免疫调节剂'}),
        ('autoimmune-research', {'en':'Autoimmune disease research','de':'Autoimmunerkrankungs-Forschung','es':'Investigación en enfermedades autoinmunes','pt':'Pesquisa em doenças autoimunes','zh':'自身免疫疾病研究'}),
        ('practical-considerations', {'en':'Practical considerations','de':'Praktische Überlegungen','es':'Consideraciones prácticas','pt':'Considerações práticas','zh':'实际注意事项'}),
    ],
    {'en':'Cannabis interacts with the immune system primarily through CB2 receptors found on immune cells. Research suggests cannabinoids can modulate immune responses, potentially benefiting autoimmune conditions while requiring caution in immunocompromised individuals.','de':'Cannabis interagiert mit dem Immunsystem hauptsächlich über CB2-Rezeptoren auf Immunzellen. Forschung zeigt, dass Cannabinoide Immunreaktionen modulieren können, was bei Autoimmunerkrankungen vorteilhaft sein kann.','es':'El cannabis interactúa con el sistema inmunológico principalmente a través de los receptores CB2 en las células inmunes. La investigación sugiere que los cannabinoides pueden modular las respuestas inmunes, beneficiando potencialmente las condiciones autoinmunes.','pt':'A cannabis interage com o sistema imunológico principalmente através dos receptores CB2 nas células imunes. Pesquisas sugerem que os canabinoides podem modular as respostas imunológicas, beneficiando potencialmente condições autoimunes.','zh':'大麻主要通过免疫细胞上的CB2受体与免疫系统互动。研究表明大麻素可以调节免疫反应，可能有益于自身免疫性疾病，但免疫功能低下者需要谨慎。'},
    [
        ('endocannabinoid-overview',
         {'en':'The endocannabinoid system and immunity','de':'Das Endocannabinoid-System und Immunität','es':'El sistema endocannabinoide y la inmunidad','pt':'O sistema endocanabinoide e a imunidade','zh':'内源性大麻素系统与免疫'},
         {'en':['The endocannabinoid system (ECS) is a complex cell-signaling network that plays a crucial role in regulating immune function, inflammation, and cellular homeostasis. Discovered in the early 1990s during research on THC, the ECS consists of endocannabinoids (molecules your body produces naturally), receptors (CB1 and CB2), and enzymes that break down these molecules after they have served their purpose.','While CB1 receptors are concentrated in the brain and central nervous system, CB2 receptors are found predominantly on immune cells, including macrophages, B-cells, T-cells, and natural killer cells. This distribution strongly suggests that the ECS evolved, at least in part, as a regulatory mechanism for the immune system. When you consume cannabis, the phytocannabinoids THC and CBD interact with these same receptors, which is why cannabis can have such pronounced effects on immune function.'],
          'de':['Das Endocannabinoid-System (ECS) ist ein komplexes Zellsignalnetzwerk, das eine entscheidende Rolle bei der Regulierung der Immunfunktion, Entzündung und zellulären Homöostase spielt. In den frühen 1990er Jahren während der THC-Forschung entdeckt, besteht das ECS aus Endocannabinoiden, Rezeptoren (CB1 und CB2) und Enzymen, die diese Moleküle abbauen.','Während CB1-Rezeptoren im Gehirn und Zentralnervensystem konzentriert sind, finden sich CB2-Rezeptoren vorwiegend auf Immunzellen, einschließlich Makrophagen, B-Zellen, T-Zellen und natürlichen Killerzellen. Diese Verteilung deutet darauf hin, dass sich das ECS als Regulierungsmechanismus für das Immunsystem entwickelt hat.'],
          'es':['El sistema endocannabinoide (SEC) es una red compleja de señalización celular que desempeña un papel crucial en la regulación de la función inmune, la inflamación y la homeostasis celular. Descubierto a principios de los años 90 durante la investigación sobre el THC, el SEC consiste en endocannabinoides, receptores (CB1 y CB2) y enzimas que descomponen estas moléculas.','Mientras que los receptores CB1 se concentran en el cerebro y el sistema nervioso central, los receptores CB2 se encuentran predominantemente en las células inmunes, incluyendo macrófagos, células B, células T y células asesinas naturales. Esta distribución sugiere fuertemente que el SEC evolucionó como mecanismo regulador del sistema inmunológico.'],
          'pt':['O sistema endocanabinoide (SEC) é uma rede complexa de sinalização celular que desempenha um papel crucial na regulação da função imunológica, inflamação e homeostase celular. Descoberto no início dos anos 1990 durante pesquisas sobre o THC, o SEC consiste em endocanabinoides, receptores (CB1 e CB2) e enzimas que decompõem essas moléculas.','Enquanto os receptores CB1 estão concentrados no cérebro e sistema nervoso central, os receptores CB2 são encontrados predominantemente em células imunes, incluindo macrófagos, células B, células T e células exterminadoras naturais. Essa distribuição sugere fortemente que o SEC evoluiu como mecanismo regulador do sistema imunológico.'],
          'zh':['内源性大麻素系统（ECS）是一个复杂的细胞信号网络，在调节免疫功能、炎症和细胞稳态方面发挥着关键作用。ECS在20世纪90年代初THC研究期间被发现，由内源性大麻素、受体（CB1和CB2）和分解这些分子的酶组成。','虽然CB1受体集中在大脑和中枢神经系统，但CB2受体主要存在于免疫细胞上，包括巨噬细胞、B细胞、T细胞和自然杀伤细胞。这种分布强烈表明ECS至少部分地作为免疫系统的调节机制而进化。当您使用大麻时，植物大麻素THC和CBD与这些相同的受体互动，这就是大麻对免疫功能产生显著影响的原因。']}),
        ('cb2-receptors',
         {'en':'CB2 receptors and immune cells','de':'CB2-Rezeptoren und Immunzellen','es':'Receptores CB2 y células inmunes','pt':'Receptores CB2 e células imunes','zh':'CB2受体与免疫细胞'},
         {'en':['CB2 receptors are the primary interface between cannabinoids and the immune system. These receptors are expressed on virtually every type of immune cell, and their activation can either stimulate or suppress immune activity depending on the context, the specific cannabinoid involved, and the state of the immune system at the time of exposure.','Research has shown that activating CB2 receptors can reduce the production of pro-inflammatory cytokines — signaling molecules that promote inflammation — while simultaneously increasing anti-inflammatory cytokines. This dual action is what makes cannabinoids particularly interesting for conditions characterized by excessive or misdirected inflammation, such as autoimmune diseases, allergies, and chronic inflammatory conditions.'],
          'de':['CB2-Rezeptoren sind die primäre Schnittstelle zwischen Cannabinoiden und dem Immunsystem. Diese Rezeptoren werden auf praktisch jedem Typ von Immunzellen exprimiert, und ihre Aktivierung kann die Immunaktivität je nach Kontext entweder stimulieren oder unterdrücken.','Forschung hat gezeigt, dass die Aktivierung von CB2-Rezeptoren die Produktion von pro-inflammatorischen Zytokinen reduzieren kann, während gleichzeitig anti-inflammatorische Zytokine erhöht werden. Diese duale Wirkung macht Cannabinoide besonders interessant für Erkrankungen mit übermäßiger Entzündung.'],
          'es':['Los receptores CB2 son la interfaz principal entre los cannabinoides y el sistema inmunológico. Estos receptores se expresan en prácticamente todos los tipos de células inmunes, y su activación puede estimular o suprimir la actividad inmune según el contexto.','La investigación ha demostrado que la activación de los receptores CB2 puede reducir la producción de citoquinas proinflamatorias mientras aumenta simultáneamente las citoquinas antiinflamatorias. Esta acción dual hace que los cannabinoides sean particularmente interesantes para condiciones con inflamación excesiva.'],
          'pt':['Os receptores CB2 são a interface primária entre os canabinoides e o sistema imunológico. Esses receptores são expressos em praticamente todos os tipos de células imunes, e sua ativação pode estimular ou suprimir a atividade imune dependendo do contexto.','Pesquisas mostraram que a ativação dos receptores CB2 pode reduzir a produção de citocinas pró-inflamatórias enquanto aumenta simultaneamente as citocinas anti-inflamatórias. Essa ação dupla torna os canabinoides particularmente interessantes para condições com inflamação excessiva.'],
          'zh':['CB2受体是大麻素与免疫系统之间的主要接口。这些受体几乎在每种类型的免疫细胞上都有表达，其激活可以根据上下文刺激或抑制免疫活动。','研究表明，激活CB2受体可以减少促炎细胞因子的产生，同时增加抗炎细胞因子。这种双重作用使大麻素对于以过度炎症为特征的疾病特别有趣，如自身免疫疾病和慢性炎症。']}),
        ('immunomodulation',
         {'en':'Cannabis as an immunomodulator','de':'Cannabis als Immunmodulator','es':'Cannabis como inmunomodulador','pt':'Cannabis como imunomodulador','zh':'大麻作为免疫调节剂'},
         {'en':['Unlike immunosuppressants that broadly shut down immune activity, cannabis appears to function as an immunomodulator — meaning it helps regulate and balance the immune response rather than simply suppressing it. This distinction is important because immunomodulation preserves the immune system\'s ability to fight infections and cancer while reducing harmful overreactions.','CBD in particular has demonstrated significant immunomodulatory properties in preclinical studies. It has been shown to reduce T-cell proliferation, decrease inflammatory cytokine production, and promote regulatory T-cells (Tregs) that help maintain immune tolerance. THC also has immunomodulatory effects, though its psychoactive properties make it more complex to study in clinical settings.'],
          'de':['Anders als Immunsuppressiva, die die Immunaktivität breit unterdrücken, scheint Cannabis als Immunmodulator zu wirken — es hilft die Immunantwort zu regulieren und auszubalancieren, anstatt sie einfach zu unterdrücken. Diese Unterscheidung ist wichtig, da Immunmodulation die Fähigkeit des Immunsystems bewahrt, Infektionen zu bekämpfen.','CBD hat in präklinischen Studien bedeutende immunmodulatorische Eigenschaften gezeigt. Es reduziert die T-Zell-Proliferation, vermindert die Produktion entzündlicher Zytokine und fördert regulatorische T-Zellen, die die Immuntoleranz aufrechterhalten.'],
          'es':['A diferencia de los inmunosupresores que suprimen ampliamente la actividad inmune, el cannabis parece funcionar como inmunomodulador — ayuda a regular y equilibrar la respuesta inmune en lugar de simplemente suprimirla. Esta distinción es importante porque la inmunomodulación preserva la capacidad del sistema inmune para combatir infecciones.','El CBD en particular ha demostrado propiedades inmunomoduladoras significativas en estudios preclínicos. Se ha demostrado que reduce la proliferación de células T, disminuye la producción de citoquinas inflamatorias y promueve las células T reguladoras.'],
          'pt':['Diferentemente dos imunossupressores que suprimem amplamente a atividade imune, a cannabis parece funcionar como um imunomodulador — ajudando a regular e equilibrar a resposta imune em vez de simplesmente suprimi-la. Esta distinção é importante porque a imunomodulação preserva a capacidade do sistema imunológico de combater infecções.','O CBD em particular demonstrou propriedades imunomoduladoras significativas em estudos pré-clínicos. Foi demonstrado que reduz a proliferação de células T, diminui a produção de citocinas inflamatórias e promove células T reguladoras.'],
          'zh':['与广泛关闭免疫活动的免疫抑制剂不同，大麻似乎作为免疫调节剂发挥作用——帮助调节和平衡免疫反应，而不是简单地抑制它。这种区别很重要，因为免疫调节保留了免疫系统对抗感染的能力。','CBD在临床前研究中显示出显著的免疫调节特性。它被证明可以减少T细胞增殖，降低炎症细胞因子的产生，并促进维持免疫耐受的调节性T细胞。']}),
        ('autoimmune-research',
         {'en':'Autoimmune disease research','de':'Autoimmunerkrankungs-Forschung','es':'Investigación en enfermedades autoinmunes','pt':'Pesquisa em doenças autoimunes','zh':'自身免疫疾病研究'},
         {'en':['Autoimmune diseases — conditions where the immune system mistakenly attacks the body\'s own tissues — represent one of the most promising areas for cannabis-based treatments. Conditions like rheumatoid arthritis, multiple sclerosis, Crohn\'s disease, and lupus all involve chronic inflammation driven by an overactive immune system, and cannabinoids\' ability to modulate immune responses makes them natural candidates for investigation.','Clinical evidence is growing but still limited. Several studies on multiple sclerosis patients have shown that cannabis-based medicines like Sativex can reduce spasticity and pain. Research on Crohn\'s disease has shown mixed results, with some studies finding significant symptom improvement while others found no difference compared to placebo. The challenge with autoimmune research is that these diseases are highly variable between individuals.'],
          'de':['Autoimmunerkrankungen — Zustände, bei denen das Immunsystem fälschlicherweise körpereigenes Gewebe angreift — stellen einen der vielversprechendsten Bereiche für Cannabis-basierte Behandlungen dar. Erkrankungen wie rheumatoide Arthritis, Multiple Sklerose, Morbus Crohn und Lupus beinhalten chronische Entzündungen durch ein überaktives Immunsystem.','Klinische Evidenz wächst, ist aber noch begrenzt. Mehrere Studien an Multiple-Sklerose-Patienten haben gezeigt, dass Cannabis-basierte Medikamente wie Sativex Spastizität und Schmerzen reduzieren können. Die Forschung zu Morbus Crohn zeigt gemischte Ergebnisse.'],
          'es':['Las enfermedades autoinmunes — condiciones donde el sistema inmunológico ataca erróneamente los propios tejidos del cuerpo — representan una de las áreas más prometedoras para tratamientos basados en cannabis. Condiciones como artritis reumatoide, esclerosis múltiple, enfermedad de Crohn y lupus involucran inflamación crónica por un sistema inmune hiperactivo.','La evidencia clínica está creciendo pero aún es limitada. Varios estudios en pacientes con esclerosis múltiple han demostrado que medicamentos basados en cannabis como Sativex pueden reducir la espasticidad y el dolor.'],
          'pt':['Doenças autoimunes — condições em que o sistema imunológico ataca erroneamente os tecidos do próprio corpo — representam uma das áreas mais promissoras para tratamentos à base de cannabis. Condições como artrite reumatoide, esclerose múltipla, doença de Crohn e lúpus envolvem inflamação crônica causada por um sistema imune hiperativo.','A evidência clínica está crescendo, mas ainda é limitada. Vários estudos em pacientes com esclerose múltipla mostraram que medicamentos à base de cannabis como o Sativex podem reduzir a espasticidade e a dor.'],
          'zh':['自身免疫疾病——免疫系统错误地攻击身体自身组织的疾病——代表了大麻治疗最有前景的领域之一。类风湿性关节炎、多发性硬化症、克罗恩病和红斑狼疮等疾病都涉及过度活跃的免疫系统驱动的慢性炎症。','临床证据在增长但仍然有限。多项针对多发性硬化症患者的研究表明，基于大麻的药物如Sativex可以减少痉挛和疼痛。克罗恩病的研究显示了混合结果。']}),
        ('practical-considerations',
         {'en':'Practical considerations','de':'Praktische Überlegungen','es':'Consideraciones prácticas','pt':'Considerações práticas','zh':'实际注意事项'},
         {'en':['If you are considering using cannabis for immune-related conditions, there are several important factors to keep in mind. First, cannabis affects the immune system differently depending on whether you are healthy or dealing with an immune disorder. In healthy individuals, the immunosuppressive effects of THC could theoretically make you slightly more susceptible to infections, though this effect appears to be modest at typical recreational or medicinal doses.','For those with autoimmune conditions, the immunomodulatory properties of cannabis — particularly CBD — may offer benefits, but they should be viewed as a complement to conventional treatment rather than a replacement. Always discuss cannabis use with your healthcare provider, especially if you are taking immunosuppressive medications, as there may be interactions that alter the effectiveness of your prescribed treatments.'],
          'de':['Wenn Sie Cannabis für immunbezogene Erkrankungen in Betracht ziehen, gibt es mehrere wichtige Faktoren zu beachten. Cannabis beeinflusst das Immunsystem unterschiedlich, je nachdem ob Sie gesund sind oder eine Immunstörung haben. Bei gesunden Personen könnten die immunsuppressiven Effekte von THC theoretisch die Infektionsanfälligkeit leicht erhöhen.','Für Personen mit Autoimmunerkrankungen können die immunmodulatorischen Eigenschaften von Cannabis — insbesondere CBD — Vorteile bieten, sollten aber als Ergänzung zur konventionellen Behandlung betrachtet werden. Besprechen Sie die Cannabis-Nutzung immer mit Ihrem Arzt.'],
          'es':['Si está considerando usar cannabis para condiciones relacionadas con el sistema inmune, hay varios factores importantes a tener en cuenta. El cannabis afecta al sistema inmunológico de manera diferente dependiendo de si está sano o tiene un trastorno inmune.','Para aquellos con condiciones autoinmunes, las propiedades inmunomoduladoras del cannabis — particularmente el CBD — pueden ofrecer beneficios, pero deben verse como complemento al tratamiento convencional. Siempre discuta el uso de cannabis con su proveedor de salud.'],
          'pt':['Se você está considerando usar cannabis para condições relacionadas ao sistema imune, há vários fatores importantes a ter em mente. A cannabis afeta o sistema imunológico de maneira diferente dependendo de se você é saudável ou está lidando com um distúrbio imune.','Para aqueles com condições autoimunes, as propriedades imunomoduladoras da cannabis — particularmente o CBD — podem oferecer benefícios, mas devem ser vistas como complemento ao tratamento convencional. Sempre discuta o uso de cannabis com seu médico.'],
          'zh':['如果您正在考虑使用大麻治疗免疫相关疾病，有几个重要因素需要记住。大麻对免疫系统的影响取决于您是健康的还是正在处理免疫疾病。在健康个体中，THC的免疫抑制作用理论上可能会略微增加感染易感性。','对于自身免疫疾病患者，大麻的免疫调节特性——特别是CBD——可能提供益处，但应被视为传统治疗的补充而非替代。请始终与您的医疗保健提供者讨论大麻的使用。']}),
    ],
    [
        ({'en':'Can cannabis boost your immune system?','de':'Kann Cannabis Ihr Immunsystem stärken?','es':'¿Puede el cannabis fortalecer su sistema inmunológico?','pt':'A cannabis pode fortalecer seu sistema imunológico?','zh':'大麻能增强您的免疫系统吗？'},
         {'en':'Cannabis does not simply boost the immune system. Instead, it acts as an immunomodulator, meaning it can help regulate immune responses. It may reduce overactive immune responses in autoimmune conditions while its effects on healthy immune function are more nuanced and dose-dependent.','de':'Cannabis stärkt das Immunsystem nicht einfach. Stattdessen wirkt es als Immunmodulator und kann helfen, Immunreaktionen zu regulieren. Es kann überaktive Immunreaktionen bei Autoimmunerkrankungen reduzieren.','es':'El cannabis no simplemente fortalece el sistema inmunológico. Actúa como inmunomodulador, ayudando a regular las respuestas inmunes. Puede reducir las respuestas inmunes hiperactivas en condiciones autoinmunes.','pt':'A cannabis não simplesmente fortalece o sistema imunológico. Em vez disso, atua como imunomodulador, ajudando a regular as respostas imunes. Pode reduzir respostas imunes hiperativas em condições autoimunes.','zh':'大麻并不简单地增强免疫系统。它作为免疫调节剂，帮助调节免疫反应。它可以减少自身免疫疾病中的过度活跃免疫反应。'}),
        ({'en':'Is cannabis safe for people with weakened immune systems?','de':'Ist Cannabis sicher für Menschen mit geschwächtem Immunsystem?','es':'¿Es seguro el cannabis para personas con sistema inmune debilitado?','pt':'A cannabis é segura para pessoas com sistema imunológico enfraquecido?','zh':'大麻对免疫系统减弱的人安全吗？'},
         {'en':'People with weakened immune systems should exercise caution with cannabis, particularly with THC, which has immunosuppressive properties. CBD may be a better option as it appears to have immunomodulatory rather than broadly immunosuppressive effects. Always consult your doctor before using cannabis if you are immunocompromised.','de':'Menschen mit geschwächtem Immunsystem sollten bei Cannabis Vorsicht walten lassen, besonders bei THC, das immunsuppressive Eigenschaften hat. CBD könnte eine bessere Option sein. Konsultieren Sie immer Ihren Arzt.','es':'Las personas con sistemas inmunes debilitados deben tener precaución con el cannabis, particularmente con el THC. El CBD puede ser una mejor opción. Siempre consulte a su médico.','pt':'Pessoas com sistemas imunológicos enfraquecidos devem ter cautela com cannabis, particularmente com THC. O CBD pode ser uma opção melhor. Sempre consulte seu médico.','zh':'免疫系统减弱的人应该谨慎使用大麻，特别是具有免疫抑制特性的THC。CBD可能是更好的选择。请始终咨询您的医生。'}),
        ({'en':'Which cannabinoid is best for autoimmune conditions?','de':'Welches Cannabinoid ist am besten für Autoimmunerkrankungen?','es':'¿Qué cannabinoide es mejor para condiciones autoinmunes?','pt':'Qual canabinoide é melhor para condições autoimunes?','zh':'哪种大麻素最适合自身免疫疾病？'},
         {'en':'CBD is generally considered the most promising cannabinoid for autoimmune conditions due to its anti-inflammatory and immunomodulatory properties without significant psychoactive effects. However, some research suggests that a combination of CBD and low-dose THC may be more effective due to the entourage effect.','de':'CBD wird allgemein als das vielversprechendste Cannabinoid für Autoimmunerkrankungen angesehen, aufgrund seiner entzündungshemmenden und immunmodulatorischen Eigenschaften ohne signifikante psychoaktive Wirkungen.','es':'El CBD se considera generalmente el cannabinoide más prometedor para condiciones autoinmunes debido a sus propiedades antiinflamatorias e inmunomoduladoras sin efectos psicoactivos significativos.','pt':'O CBD é geralmente considerado o canabinoide mais promissor para condições autoimunes devido às suas propriedades anti-inflamatórias e imunomoduladoras sem efeitos psicoativos significativos.','zh':'CBD通常被认为是最有前景的自身免疫疾病大麻素，因为它具有抗炎和免疫调节特性，且没有显著的精神活性作用。'}),
    ],
    [4, 7, 0],  # related: inflammation, entourage, cbd-vs-thc
)

ARTICLES_DEF.append(a1)
print(f"  Defined article 1: {a1['slug']}")
