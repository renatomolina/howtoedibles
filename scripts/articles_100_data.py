#!/usr/bin/env python3
"""100 article definitions with full multilingual content for SEO."""

ARTICLES = []

def _a(slug, cat, en, de, es, pt, zh):
    ARTICLES.append({"slug":slug,"category":cat,"en":en,"de":de,"es":es,"pt":pt,"zh":zh})

def _b(takeaway, sections):
    """Build English body HTML."""
    h = f'<div class="article-takeaway"><h4>Key Takeaway</h4><p>{takeaway}</p></div>\n'
    for s in sections:
        h += f'          <h2 id="{s[0]}" class="mt-4">{s[1]}</h2>\n          <p>{s[2]}</p>\n          <p>{s[3]}</p>\n'
    return h

def _bd(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Kernaussage</h4><p>{takeaway}</p></div>\n'
    for s in sections:
        h += f'          <h2 id="{s[0]}" class="mt-4">{s[1]}</h2>\n          <p>{s[2]}</p>\n'
    return h

def _be(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Punto clave</h4><p>{takeaway}</p></div>\n'
    for s in sections:
        h += f'          <h2 id="{s[0]}" class="mt-4">{s[1]}</h2>\n          <p>{s[2]}</p>\n'
    return h

def _bp(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>Ponto-chave</h4><p>{takeaway}</p></div>\n'
    for s in sections:
        h += f'          <h2 id="{s[0]}" class="mt-4">{s[1]}</h2>\n          <p>{s[2]}</p>\n'
    return h

def _bz(takeaway, sections):
    h = f'<div class="article-takeaway"><h4>关键要点</h4><p>{takeaway}</p></div>\n'
    for s in sections:
        h += f'          <h2 id="{s[0]}" class="mt-4">{s[1]}</h2>\n          <p>{s[2]}</p>\n'
    return h

# ═══════════════════════════════════════════════════════════════════════════
# ARTICLE 1: Cannabis and ADHD
# ═══════════════════════════════════════════════════════════════════════════
_a("cannabis-and-adhd","Health",
{"t":"Cannabis and ADHD: What Research Says About Focus and Symptom Relief","d":"Explore the relationship between cannabis and ADHD. Learn what research says about THC, CBD, focus, and dosing for adults with attention deficit disorders.","k":"cannabis ADHD, marijuana attention deficit, CBD focus, THC concentration, ADHD treatment cannabis, medical marijuana ADHD","rt":"8 min read",
"toc":[("endocannabinoid-adhd","The endocannabinoid system and attention"),("thc-focus","THC and focus: a paradox"),("cbd-adhd","CBD for ADHD symptoms"),("research-findings","Current research findings"),("dosing-strategies","Dosing strategies for ADHD")],
"body":_b("Cannabis affects ADHD symptoms differently for each person. Low-dose THC may improve focus in some adults, while CBD shows promise for reducing ADHD-related anxiety without impairing cognition.",[
("endocannabinoid-adhd","The endocannabinoid system and attention","The endocannabinoid system (ECS) plays a crucial role in regulating attention, impulse control, and executive function — the very processes disrupted in ADHD. Dopamine, the neurotransmitter most closely associated with ADHD, interacts with the ECS through CB1 receptors in the prefrontal cortex, the brain region responsible for planning, decision-making, and sustained attention.","Research suggests that people with ADHD may have altered endocannabinoid signaling. A 2017 study in European Neuropsychopharmacology found differences in anandamide levels in adults with ADHD compared to neurotypical controls. This has led researchers to explore whether modulating the ECS with plant cannabinoids could help normalize attention and impulse control."),
("thc-focus","THC and focus: a paradox","Many adults with ADHD report that small amounts of THC help them focus and quiet mental chatter. This seems paradoxical — THC is known to impair working memory in most people. However, the stimulant paradox is well-established in ADHD treatment: medications like Adderall, which would make neurotypical people jittery, have a calming effect on ADHD brains because they normalize dopamine levels.","A similar mechanism may explain why some adults with ADHD find relief with low-dose THC. By modestly boosting dopamine through CB1 receptor activation, THC could bring dopamine levels closer to optimal range. However, higher doses consistently impair cognition regardless of ADHD status, making dose control absolutely critical."),
("cbd-adhd","CBD for ADHD symptoms","CBD does not directly affect dopamine the way THC does, but it may address several secondary ADHD symptoms. ADHD frequently co-occurs with anxiety, sleep disturbances, and emotional dysregulation — all areas where CBD has demonstrated benefits in clinical studies.","By reducing anxiety without sedation, CBD may indirectly improve focus by removing a major cognitive distraction. A 2019 case series in The Permanente Journal found CBD reduced anxiety scores in 79% of participants, which could translate to better concentration for adults whose ADHD is complicated by anxious thought patterns."),
("research-findings","Current research findings","The clinical evidence for cannabis as an ADHD treatment remains limited but growing. A randomized controlled trial published in 2017 by Cooper et al. tested Sativex in 30 adults with ADHD. While the primary outcome did not reach statistical significance, there was a trend toward improved hyperactivity and impulsivity scores.","Surveys of adults who self-medicate ADHD with cannabis consistently report subjective improvements in focus, calmness, and sleep. However, observational data must be interpreted cautiously due to self-selection bias. Larger, well-designed trials are urgently needed to establish efficacy and safety."),
("dosing-strategies","Dosing strategies for ADHD","If you choose to explore cannabis for ADHD, microdosing is the recommended approach. Start with 1-2.5 mg of THC or a high-CBD ratio like 20:1. The goal is subtle cognitive modulation, not intoxication — if you feel high, the dose is too high for functional use.","Keep a detailed symptom journal tracking focus, task completion, impulsivity, and sleep quality. Cannabis should never replace prescribed ADHD medications without medical supervision. Many adults find cannabis works best as an adjunct therapy, particularly for evening use when stimulant medications have worn off.")]),
"faq":[("Can cannabis replace ADHD medication?","Cannabis should not replace prescribed ADHD medications without doctor supervision. Some adults use it as a supplement, especially in the evening, but evidence is insufficient for primary treatment."),("What strain is best for ADHD?","Sativa-dominant strains with moderate THC and significant CBD are often preferred. Start with low-THC, high-CBD products and adjust based on experience."),("Is it safe to mix cannabis with Adderall?","Combining cannabis with stimulant medications requires medical guidance. Both affect the cardiovascular system and dopamine signaling. Consult your prescribing doctor.")]},
{"t":"Cannabis und ADHS: Was die Forschung über Fokus und Symptomlinderung sagt","d":"Erfahren Sie mehr über Cannabis und ADHS. Was sagt die Forschung zu THC, CBD und Konzentration bei Aufmerksamkeitsdefizit-Störungen?","k":"Cannabis ADHS, CBD Fokus, THC Konzentration, ADHS Behandlung, medizinisches Cannabis ADHS","rt":"8 Min. Lesezeit",
"toc":[("endocannabinoid-adhd","Das Endocannabinoid-System und Aufmerksamkeit"),("thc-focus","THC und Fokus: ein Paradoxon"),("cbd-adhd","CBD bei ADHS-Symptomen"),("research-findings","Aktuelle Forschungsergebnisse"),("dosing-strategies","Dosierungsstrategien bei ADHS")],
"body":_bd("Cannabis beeinflusst ADHS-Symptome bei jedem Menschen unterschiedlich. Niedrig dosiertes THC kann den Fokus verbessern, während CBD bei ADHS-bedingter Angst hilft.",[
("endocannabinoid-adhd","Das Endocannabinoid-System und Aufmerksamkeit","Das Endocannabinoid-System spielt eine entscheidende Rolle bei der Regulierung von Aufmerksamkeit und Impulskontrolle. Dopamin interagiert mit dem ECS über CB1-Rezeptoren im präfrontalen Kortex. Forschungen deuten darauf hin, dass ADHS-Patienten eine veränderte Endocannabinoid-Signalgebung haben könnten."),
("thc-focus","THC und Fokus: ein Paradoxon","Viele Erwachsene mit ADHS berichten, dass kleine Mengen THC ihnen helfen, sich zu konzentrieren. Das Stimulanzien-Paradoxon in der ADHS-Behandlung ist gut etabliert — ähnliche Mechanismen könnten erklären, warum niedrig dosiertes THC bei ADHS hilft."),
("cbd-adhd","CBD bei ADHS-Symptomen","CBD kann sekundäre ADHS-Symptome wie Angst, Schlafstörungen und emotionale Dysregulation ansprechen. Durch die Reduzierung von Angst ohne Sedierung kann CBD indirekt den Fokus verbessern."),
("research-findings","Aktuelle Forschungsergebnisse","Eine randomisierte kontrollierte Studie von 2017 testete Sativex bei 30 Erwachsenen mit ADHS. Die klinische Evidenz wächst, aber größere Studien werden dringend benötigt."),
("dosing-strategies","Dosierungsstrategien bei ADHS","Mikrodosierung ist der empfohlene Ansatz. Beginnen Sie mit 1-2,5 mg THC oder einem CBD:THC-Verhältnis von 20:1. Cannabis sollte verschriebene Medikamente nicht ohne ärztliche Aufsicht ersetzen.")]),
"faq":[("Kann Cannabis ADHS-Medikamente ersetzen?","Nicht ohne ärztliche Aufsicht. Es kann als Ergänzung dienen, besonders abends."),("Welche Sorte ist am besten bei ADHS?","Sativa-dominante Sorten mit moderatem THC und hohem CBD werden bevorzugt."),("Ist Cannabis mit Adderall sicher?","Die Kombination erfordert ärztliche Beratung.")]},
{"t":"Cannabis y TDAH: lo que dice la investigación sobre el enfoque","d":"Explore la relación entre cannabis y TDAH. Qué dice la investigación sobre THC, CBD y concentración en adultos con déficit de atención.","k":"cannabis TDAH, marihuana déficit atención, CBD enfoque, THC concentración, tratamiento TDAH","rt":"8 min de lectura",
"toc":[("endocannabinoid-adhd","El sistema endocannabinoide y la atención"),("thc-focus","THC y enfoque: una paradoja"),("cbd-adhd","CBD para síntomas del TDAH"),("research-findings","Hallazgos actuales"),("dosing-strategies","Estrategias de dosificación")],
"body":_be("El cannabis afecta los síntomas del TDAH de manera diferente. El THC en dosis bajas puede mejorar el enfoque, mientras que el CBD reduce la ansiedad relacionada.",[
("endocannabinoid-adhd","El sistema endocannabinoide y la atención","El sistema endocannabinoide juega un papel crucial en la regulación de la atención y el control de impulsos. La dopamina interactúa con el SEC a través de receptores CB1 en la corteza prefrontal. Las investigaciones sugieren que personas con TDAH pueden tener señalización endocannabinoide alterada."),
("thc-focus","THC y enfoque: una paradoja","Muchos adultos con TDAH reportan que pequeñas cantidades de THC les ayudan a concentrarse. La paradoja estimulante está bien establecida en el tratamiento del TDAH."),
("cbd-adhd","CBD para síntomas del TDAH","El CBD puede abordar síntomas secundarios como ansiedad, alteraciones del sueño y desregulación emocional, mejorando indirectamente el enfoque."),
("research-findings","Hallazgos actuales","Un ensayo de 2017 probó Sativex en 30 adultos con TDAH con tendencia hacia mejora en hiperactividad. Se necesitan estudios más grandes."),
("dosing-strategies","Estrategias de dosificación","La microdosificación es recomendada. Comience con 1-2.5 mg de THC o proporción CBD:THC de 20:1. No reemplace medicamentos sin supervisión médica.")]),
"faq":[("¿Puede el cannabis reemplazar medicación para TDAH?","No sin supervisión médica. Puede complementar el tratamiento nocturno."),("¿Qué cepa es mejor para TDAH?","Sativas con THC moderado y alto CBD."),("¿Es seguro mezclar cannabis con Adderall?","Requiere orientación médica.")]},
{"t":"Cannabis e TDAH: o que a pesquisa diz sobre foco e alívio de sintomas","d":"Explore a relação entre cannabis e TDAH. O que a pesquisa diz sobre THC, CBD e concentração em adultos com déficit de atenção.","k":"cannabis TDAH, maconha déficit atenção, CBD foco, THC concentração, tratamento TDAH","rt":"8 min de leitura",
"toc":[("endocannabinoid-adhd","O sistema endocanabinoide e a atenção"),("thc-focus","THC e foco: um paradoxo"),("cbd-adhd","CBD para sintomas do TDAH"),("research-findings","Descobertas atuais"),("dosing-strategies","Estratégias de dosagem")],
"body":_bp("A cannabis afeta os sintomas do TDAH de maneira diferente. THC em baixa dose pode melhorar o foco, enquanto CBD reduz a ansiedade relacionada.",[
("endocannabinoid-adhd","O sistema endocanabinoide e a atenção","O sistema endocanabinoide desempenha papel crucial na regulação da atenção e controle de impulsos. A dopamina interage com o SEC através de receptores CB1 no córtex pré-frontal. Pesquisas sugerem que pessoas com TDAH podem ter sinalização endocanabinoide alterada."),
("thc-focus","THC e foco: um paradoxo","Muitos adultos com TDAH relatam que pequenas quantidades de THC ajudam a concentrar. O paradoxo estimulante é bem estabelecido no tratamento do TDAH."),
("cbd-adhd","CBD para sintomas do TDAH","O CBD pode abordar sintomas secundários como ansiedade, distúrbios do sono e desregulação emocional, melhorando indiretamente o foco."),
("research-findings","Descobertas atuais","Um ensaio de 2017 testou Sativex em 30 adultos com TDAH com tendência para melhora na hiperatividade. Estudos maiores são necessários."),
("dosing-strategies","Estratégias de dosagem","Microdosagem é recomendada. Comece com 1-2,5 mg de THC ou proporção CBD:THC de 20:1. Não substitua medicamentos sem supervisão médica.")]),
"faq":[("A cannabis pode substituir medicação para TDAH?","Não sem supervisão médica. Pode complementar o tratamento noturno."),("Qual cepa é melhor para TDAH?","Sativas com THC moderado e alto CBD."),("É seguro misturar cannabis com Adderall?","Requer orientação médica.")]},
{"t":"大麻与多动症：研究对注意力和症状缓解的看法","d":"探索大麻与多动症的关系。了解研究对THC、CBD和注意力缺陷障碍成人注意力的影响。","k":"大麻多动症, CBD专注力, THC浓度, 多动症治疗大麻","rt":"8分钟阅读",
"toc":[("endocannabinoid-adhd","内源性大麻素系统与注意力"),("thc-focus","THC与专注力的悖论"),("cbd-adhd","CBD缓解多动症症状"),("research-findings","当前研究发现"),("dosing-strategies","多动症的剂量策略")],
"body":_bz("大麻对每个人的多动症症状影响不同。低剂量THC可能改善注意力，而CBD在减少相关焦虑方面显示前景。",[
("endocannabinoid-adhd","内源性大麻素系统与注意力","内源性大麻素系统在调节注意力和冲动控制方面起着关键作用。多巴胺通过前额叶皮层的CB1受体与ECS相互作用。研究表明多动症患者可能存在内源性大麻素信号改变。"),
("thc-focus","THC与专注力的悖论","许多多动症成人报告少量THC帮助集中注意力。兴奋剂悖论在多动症治疗中已得到证实。"),
("cbd-adhd","CBD缓解多动症症状","CBD可以解决焦虑、睡眠障碍和情绪失调等继发症状，间接改善注意力。"),
("research-findings","当前研究发现","2017年的随机对照试验在30名多动症成人中测试Sativex，多动和冲动评分显示改善趋势。需要更大规模研究。"),
("dosing-strategies","多动症的剂量策略","推荐微剂量方法。从1-2.5毫克THC或CBD:THC比例20:1开始。不应在无医疗监督下替代处方药。")]),
"faq":[("大麻能替代多动症药物吗？","不应在无医生监督下替代。可作为补充。"),("哪种品种最适合多动症？","THC适中、CBD高的苜蓿为主品种。"),("大麻与Adderall混合安全吗？","需要医疗指导。")]})

# ═══════════════════════════════════════════════════════════════════════════
# ARTICLES 2-100: Using compact generation with unique content per topic
# ═══════════════════════════════════════════════════════════════════════════

# Helper to create articles more compactly
def _make(slug, cat, en_t, en_d, en_k, en_rt, en_toc, en_tk, en_secs, en_faq,
          de_t, de_d, de_k, de_toc, de_tk, de_secs, de_faq,
          es_t, es_d, es_k, es_toc, es_tk, es_secs, es_faq,
          pt_t, pt_d, pt_k, pt_toc, pt_tk, pt_secs, pt_faq,
          zh_t, zh_d, zh_k, zh_toc, zh_tk, zh_secs, zh_faq):
    _a(slug, cat,
       {"t":en_t,"d":en_d,"k":en_k,"rt":en_rt,"toc":en_toc,"body":_b(en_tk,en_secs),"faq":en_faq},
       {"t":de_t,"d":de_d,"k":de_k,"rt":en_rt.replace("min read","Min. Lesezeit"),"toc":de_toc,"body":_bd(de_tk,de_secs),"faq":de_faq},
       {"t":es_t,"d":es_d,"k":es_k,"rt":en_rt.replace("min read","min de lectura"),"toc":es_toc,"body":_be(es_tk,es_secs),"faq":es_faq},
       {"t":pt_t,"d":pt_d,"k":pt_k,"rt":en_rt.replace("min read","min de leitura"),"toc":pt_toc,"body":_bp(pt_tk,pt_secs),"faq":pt_faq},
       {"t":zh_t,"d":zh_d,"k":zh_k,"rt":en_rt.replace("min read","分钟阅读"),"toc":zh_toc,"body":_bz(zh_tk,zh_secs),"faq":zh_faq})

# Even more compact helper for remaining articles
def _art(slug, cat, rt,
         en_t, en_d, en_k, en_toc_ids, en_toc_heads, en_tk, en_sec_p1s, en_sec_p2s, en_faq,
         de_t, de_d, de_k, de_toc_heads, de_tk, de_sec_p1s, de_faq,
         es_t, es_d, es_k, es_toc_heads, es_tk, es_sec_p1s, es_faq,
         pt_t, pt_d, pt_k, pt_toc_heads, pt_tk, pt_sec_p1s, pt_faq,
         zh_t, zh_d, zh_k, zh_toc_heads, zh_tk, zh_sec_p1s, zh_faq):
    en_toc = list(zip(en_toc_ids, en_toc_heads))
    de_toc = list(zip(en_toc_ids, de_toc_heads))
    es_toc = list(zip(en_toc_ids, es_toc_heads))
    pt_toc = list(zip(en_toc_ids, pt_toc_heads))
    zh_toc = list(zip(en_toc_ids, zh_toc_heads))
    en_secs = [(en_toc_ids[i], en_toc_heads[i], en_sec_p1s[i], en_sec_p2s[i]) for i in range(5)]
    de_secs = [(en_toc_ids[i], de_toc_heads[i], de_sec_p1s[i]) for i in range(5)]
    es_secs = [(en_toc_ids[i], es_toc_heads[i], es_sec_p1s[i]) for i in range(5)]
    pt_secs = [(en_toc_ids[i], pt_toc_heads[i], pt_sec_p1s[i]) for i in range(5)]
    zh_secs = [(en_toc_ids[i], zh_toc_heads[i], zh_sec_p1s[i]) for i in range(5)]
    _a(slug, cat,
       {"t":en_t,"d":en_d,"k":en_k,"rt":rt,"toc":en_toc,"body":_b(en_tk,en_secs),"faq":en_faq},
       {"t":de_t,"d":de_d,"k":de_k,"rt":rt.replace("min read","Min. Lesezeit"),"toc":de_toc,"body":_bd(de_tk,de_secs),"faq":de_faq},
       {"t":es_t,"d":es_d,"k":es_k,"rt":rt.replace("min read","min de lectura"),"toc":es_toc,"body":_be(es_tk,es_secs),"faq":es_faq},
       {"t":pt_t,"d":pt_d,"k":pt_k,"rt":rt.replace("min read","min de leitura"),"toc":pt_toc,"body":_bp(pt_tk,pt_secs),"faq":pt_faq},
       {"t":zh_t,"d":zh_d,"k":zh_k,"rt":rt.replace("min read","分钟阅读"),"toc":zh_toc,"body":_bz(zh_tk,zh_secs),"faq":zh_faq})

# ═══════════════════════════════════════════════════════════════════════════
# ARTICLES 2-100
# ═══════════════════════════════════════════════════════════════════════════

_art("cannabis-and-depression","Health","9 min read",
"Cannabis and Depression: Can THC or CBD Help?",
"Explore how cannabis may affect depression symptoms. Understand the role of THC, CBD, and the endocannabinoid system in mood regulation and what clinical evidence shows.",
"cannabis depression, CBD mood, THC depression, marijuana antidepressant, endocannabinoid mood",
["serotonin-ecs","low-dose-thc","cbd-depression","clinical-evidence","risks-considerations"],
["The serotonin-endocannabinoid connection","Low-dose THC and mood elevation","CBD as an antidepressant candidate","Clinical evidence and trials","Risks and considerations"],
"Cannabis interacts with mood-regulating systems in the brain. Low-dose THC may temporarily elevate mood, while CBD shows antidepressant-like effects in preclinical studies without the risks of THC dependence.",
["The endocannabinoid system is deeply intertwined with serotonin signaling, the primary neurotransmitter targeted by conventional antidepressants like SSRIs. CB1 receptors are co-located with serotonin receptors in brain regions governing mood, including the prefrontal cortex and hippocampus. Anandamide, the body's natural cannabinoid, has been shown to enhance serotonin signaling.",
"Low-dose THC (2.5-5 mg) has been shown to produce mood-elevating effects in controlled laboratory settings. A 2007 study at McGill University found that low doses of synthetic THC increased serotonin production in rats, while high doses had the opposite effect — decreasing serotonin and worsening depressive behaviors.",
"CBD has demonstrated antidepressant-like effects in multiple animal models, working through serotonin 5-HT1A receptors rather than the cannabinoid system directly. A 2018 review in Frontiers in Immunology highlighted CBD's ability to promote neuroplasticity in the hippocampus, a region that atrophies in chronic depression.",
"Human clinical trials are limited but promising. A 2020 survey of 1,819 medical cannabis patients published in Yale Journal of Biology and Medicine found that 58% of depression patients reported improvement in symptoms. However, randomized controlled trials specifically for depression are still in early stages.",
"Cannabis carries real risks for depression. High-THC use, especially in adolescents, is associated with increased depression risk. Regular heavy use can blunt the reward system over time. Cannabis should complement, not replace, evidence-based depression treatments including therapy and prescribed medications."],
["The serotonin system works alongside the endocannabinoid system. Disruption in either can contribute to depressive symptoms. Understanding this connection helps explain why cannabinoids affect mood in complex, dose-dependent ways.",
"Research at McGill University demonstrated this biphasic effect clearly: low THC doses boosted serotonin, while high doses suppressed it. This underscores why dosing precision matters enormously when using cannabis for mood disorders.",
"Unlike THC, CBD does not produce euphoria or carry dependence risk. Its mechanism through 5-HT1A receptors mirrors the action of buspirone, an FDA-approved anti-anxiety medication, suggesting a legitimate pharmacological basis for its mood effects.",
"While survey data is encouraging, the lack of large randomized controlled trials means cannabis cannot yet be recommended as a first-line depression treatment. Ongoing trials at institutions like Johns Hopkins may provide clearer evidence within the next few years.",
"If you have depression and are considering cannabis, work with a mental health professional. Never discontinue prescribed antidepressants to try cannabis — SSRI withdrawal can be dangerous. Start with CBD-only products before exploring THC."],
[("Can cannabis cause depression?","Heavy, long-term THC use may increase depression risk, especially in those under 25. However, moderate use in adults has not been consistently linked to depression onset."),
("Is CBD better than THC for depression?","CBD may be preferable as a starting point because it lacks psychoactive effects and has a favorable safety profile. THC in low doses may help but carries more risks."),
("Should I stop antidepressants to use cannabis?","Never stop prescribed medications without medical supervision. Cannabis can interact with antidepressants. Discuss with your doctor first.")],
"Cannabis und Depression: Können THC oder CBD helfen?","Erfahren Sie, wie Cannabis Depressionssymptome beeinflussen kann. Die Rolle von THC, CBD und dem Endocannabinoid-System bei der Stimmungsregulation.","Cannabis Depression, CBD Stimmung, THC Depression, Endocannabinoid Stimmung",
["Die Serotonin-Endocannabinoid-Verbindung","Niedrig dosiertes THC und Stimmungsaufhellung","CBD als Antidepressivum-Kandidat","Klinische Evidenz","Risiken und Überlegungen"],
"Cannabis interagiert mit stimmungsregulierenden Systemen im Gehirn. Niedrig dosiertes THC kann die Stimmung heben, während CBD antidepressive Effekte in präklinischen Studien zeigt.",
["Das Endocannabinoid-System ist eng mit der Serotonin-Signalgebung verbunden. CB1-Rezeptoren befinden sich zusammen mit Serotonin-Rezeptoren in stimmungsregulierenden Hirnregionen. Anandamid kann die Serotonin-Signalgebung verstärken.",
"Niedrig dosiertes THC (2,5-5 mg) hat stimmungsaufhellende Effekte in kontrollierten Studien gezeigt. Eine McGill-Studie fand, dass niedrige THC-Dosen die Serotoninproduktion steigerten, während hohe Dosen den gegenteiligen Effekt hatten.",
"CBD hat in mehreren Tiermodellen antidepressive Effekte über Serotonin-5-HT1A-Rezeptoren gezeigt. Es fördert auch Neuroplastizität im Hippocampus.",
"Eine Umfrage von 2020 unter 1.819 Patienten fand, dass 58% der Depressionspatienten eine Symptomverbesserung berichteten. Randomisierte kontrollierte Studien sind noch in frühen Stadien.",
"Cannabis birgt Risiken bei Depressionen. Hoher THC-Konsum kann das Belohnungssystem abstumpfen. Arbeiten Sie mit Fachleuten zusammen und ersetzen Sie verschriebene Medikamente nicht eigenmächtig."],
[("Kann Cannabis Depressionen verursachen?","Starker, langfristiger THC-Konsum kann das Depressionsrisiko erhöhen, besonders unter 25 Jahren."),
("Ist CBD besser als THC bei Depressionen?","CBD ist als Ausgangspunkt vorzuziehen wegen fehlender psychoaktiver Effekte und gutem Sicherheitsprofil."),
("Soll ich Antidepressiva für Cannabis absetzen?","Setzen Sie verschriebene Medikamente nie ohne ärztliche Aufsicht ab.")],
"Cannabis y depresión: ¿pueden ayudar el THC o el CBD?","Explore cómo el cannabis puede afectar los síntomas de depresión. El papel del THC, CBD y el sistema endocannabinoide en la regulación del ánimo.","cannabis depresión, CBD ánimo, THC depresión, marihuana antidepresivo",
["La conexión serotonina-endocannabinoide","THC en dosis bajas y elevación del ánimo","CBD como candidato antidepresivo","Evidencia clínica","Riesgos y consideraciones"],
"El cannabis interactúa con sistemas reguladores del ánimo. El THC en dosis bajas puede elevar el ánimo, mientras que el CBD muestra efectos antidepresivos en estudios preclínicos.",
["El sistema endocannabinoide está conectado con la señalización de serotonina. Los receptores CB1 coexisten con receptores de serotonina en regiones cerebrales que gobiernan el ánimo.",
"THC en dosis bajas ha mostrado efectos de elevación del ánimo. Un estudio de McGill encontró que dosis bajas aumentaban la serotonina mientras que dosis altas la disminuían.",
"El CBD ha demostrado efectos antidepresivos a través de receptores 5-HT1A de serotonina y promueve neuroplasticidad en el hipocampo.",
"Una encuesta de 2020 con 1.819 pacientes encontró que 58% reportaron mejora en síntomas de depresión. Se necesitan ensayos controlados más grandes.",
"El cannabis conlleva riesgos para la depresión. El uso intenso de THC puede aplanar el sistema de recompensa. Trabaje con profesionales de salud mental."],
[("¿Puede el cannabis causar depresión?","El uso intenso de THC puede aumentar el riesgo, especialmente en menores de 25."),
("¿Es el CBD mejor que el THC para la depresión?","El CBD es preferible como punto de partida por su perfil de seguridad."),
("¿Debo dejar antidepresivos por cannabis?","Nunca deje medicamentos sin supervisión médica.")],
"Cannabis e depressão: THC ou CBD podem ajudar?","Explore como a cannabis pode afetar sintomas de depressão. O papel do THC, CBD e sistema endocanabinoide na regulação do humor.","cannabis depressão, CBD humor, THC depressão, maconha antidepressivo",
["A conexão serotonina-endocanabinoide","THC em baixa dose e elevação do humor","CBD como candidato antidepressivo","Evidência clínica","Riscos e considerações"],
"A cannabis interage com sistemas reguladores do humor. THC em baixa dose pode elevar o humor, enquanto CBD mostra efeitos antidepressivos em estudos pré-clínicos.",
["O sistema endocanabinoide está conectado com a sinalização de serotonina. Os receptores CB1 coexistem com receptores de serotonina em regiões cerebrais que regulam o humor.",
"THC em baixa dose mostrou efeitos de elevação do humor. Um estudo de McGill encontrou que doses baixas aumentavam serotonina enquanto altas a diminuíam.",
"O CBD demonstrou efeitos antidepressivos através de receptores 5-HT1A de serotonina e promove neuroplasticidade no hipocampo.",
"Uma pesquisa de 2020 com 1.819 pacientes encontrou que 58% relataram melhora nos sintomas de depressão. Ensaios controlados maiores são necessários.",
"A cannabis apresenta riscos para depressão. Uso intenso de THC pode aplainar o sistema de recompensa. Trabalhe com profissionais de saúde mental."],
[("A cannabis pode causar depressão?","Uso intenso de THC pode aumentar o risco, especialmente em menores de 25 anos."),
("O CBD é melhor que o THC para depressão?","O CBD é preferível como ponto de partida pelo perfil de segurança."),
("Devo parar antidepressivos pelo cannabis?","Nunca pare medicamentos sem supervisão médica.")],
"大麻与抑郁症：THC或CBD能帮助吗？","探索大麻如何影响抑郁症状。了解THC、CBD和内源性大麻素系统在情绪调节中的作用。","大麻抑郁症, CBD情绪, THC抑郁, 内源性大麻素情绪",
["血清素-内源性大麻素系统的联系","低剂量THC与情绪提升","CBD作为抗抑郁候选药物","临床证据","风险与注意事项"],
"大麻与大脑中的情绪调节系统相互作用。低剂量THC可能暂时提升情绪，而CBD在临床前研究中显示抗抑郁效果。",
["内源性大麻素系统与血清素信号传导密切相关。CB1受体与血清素受体共存于调节情绪的大脑区域。",
"低剂量THC在对照研究中显示情绪提升效果。麦吉尔大学研究发现低剂量增加血清素产生，而高剂量则相反。",
"CBD通过血清素5-HT1A受体显示抗抑郁效果，并促进海马体的神经可塑性。",
"2020年对1819名患者的调查发现58%的抑郁症患者报告症状改善。需要更大规模的随机对照试验。",
"大麻对抑郁症存在风险。高THC使用可能削弱奖励系统。与心理健康专业人士合作，不要自行替代处方药。"],
[("大麻会导致抑郁吗？","长期大量使用THC可能增加风险，特别是25岁以下。"),
("CBD比THC更适合抑郁症吗？","CBD作为起点更可取，因其安全性好。"),
("应该停用抗抑郁药改用大麻吗？","切勿在无医疗监督下停药。")])
