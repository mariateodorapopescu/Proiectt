"""
NLQ Engine v2 - Query Builder
==============================
Diferența față de v1:
  v1: template fix per (intent, entity) → rigidă, greu de extins
  v2: piese SQL combinate dinamic în funcție de ce entități ai găsit

Exemplu concret:
  Query: "concediile aprobate din HR din luna trecută"

  v1 → _generate_leave_list() → template fix, sperăm că prinde toate filtrele

  v2 → assembler:
    [BASE]    FROM concedii JOIN useri JOIN departament JOIN statusuri JOIN tipcon
    [COLOANE] SELECT angajat, departament, tip, start, end, zile, status  ← list mode
    [FILTRU]  AND UPPER(d.nume_dep) LIKE '%HR%'                            ← dept găsit
    [FILTRU]  AND MONTH(c.start_c) = MONTH(CURDATE()-1 MONTH)             ← temporal găsit
    [FILTRU]  AND c.status = 2                                             ← status găsit
    [ORDIN]   ORDER BY c.start_c DESC LIMIT 100

  Debug arată exact ce piese au fost folosite și de ce.

Instalare: pip install scikit-learn numpy
Rulare:    python3 nlq_engine_v2.py
"""

import re
from dataclasses import dataclass, field
from typing import Optional, List
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 1 — EXEMPLE ETICHETATE
# ══════════════════════════════════════════════════════════════════════════════

LABELED_EXAMPLES = [
    # ── angajați ──
    {"query": "cati angajati sunt in firma",
     "intent": "count", "entity": "employee", "extra": {}},
    {"query": "numarul de angajati din companie",
     "intent": "count", "entity": "employee", "extra": {}},
    {"query": "cate persoane lucreaza la noi",
     "intent": "count", "entity": "employee", "extra": {}},
    {"query": "cati oameni sunt angajati",
     "intent": "count", "entity": "employee", "extra": {}},
    {"query": "cati membri are echipa",
     "intent": "count", "entity": "employee", "extra": {}},
    {"query": "cati angajati sunt in departamentul IT",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "cate persoane sunt in HR",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "numarul de angajati din finante",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "cati oameni lucreaza in marketing",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "arata-mi toti angajatii",
     "intent": "list", "entity": "employee", "extra": {}},
    {"query": "lista angajatilor din firma",
     "intent": "list", "entity": "employee", "extra": {}},
    {"query": "care sunt angajatii din IT",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "cine lucreaza in marketing",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "arata-mi personalul din finante",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "membrii echipei de logistica",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "care sunt colegii mei din departament",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},

    # ── concedii ──
    {"query": "cine este in concediu",
     "intent": "list", "entity": "leave", "extra": {}},
    {"query": "care angajati sunt in concediu acum",
     "intent": "list", "entity": "leave", "extra": {"temporal": "today"}},
    {"query": "cine este in concediu astazi",
     "intent": "list", "entity": "leave", "extra": {"temporal": "today"}},
    {"query": "angajatii aflati in concediu",
     "intent": "list", "entity": "leave", "extra": {}},
    {"query": "concediile din luna aceasta",
     "intent": "list", "entity": "leave", "extra": {"temporal": "this_month"}},
    {"query": "concedii planificate pentru luna aceasta",
     "intent": "list", "entity": "leave", "extra": {"temporal": "this_month"}},
    {"query": "concedii viitoare",
     "intent": "list", "entity": "leave", "extra": {}},
    {"query": "concedii planificate",
     "intent": "list", "entity": "leave", "extra": {}},
    {"query": "concedii urmatoare",
     "intent": "list", "entity": "leave", "extra": {}},
    {"query": "cate concedii au fost luna trecuta",
     "intent": "count", "entity": "leave", "extra": {"temporal": "last_month"}},
    {"query": "concediile aprobate din acest an",
     "intent": "list", "entity": "leave",
     "extra": {"temporal": "this_year", "status": 2}},
    {"query": "cate concedii sunt in asteptare",
     "intent": "count", "entity": "leave", "extra": {"status": 0}},
    {"query": "concediile respinse",
     "intent": "list", "entity": "leave", "extra": {"status": -1}},
    {"query": "concediile aprobate din HR",
     "intent": "list", "entity": "leave",
     "extra": {"status": 2, "dept_hint": True}},
    {"query": "cate zile de concediu am eu",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},
    {"query": "cate zile libere mai am",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},
    {"query": "zile de concediu ramase",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},
    {"query": "cate zile de concediu mai am disponibile",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},
    {"query": "cate zile de concediu mai am disponibile anul acesta",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},
    {"query": "zile concediu disponibile",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},

    # ── departamente ──
    {"query": "arata-mi departamentele din firma",
     "intent": "list", "entity": "department", "extra": {}},
    {"query": "care sunt departamentele companiei",
     "intent": "list", "entity": "department", "extra": {}},
    {"query": "lista departamentelor",
     "intent": "list", "entity": "department", "extra": {}},
    {"query": "ce departamente exista",
     "intent": "list", "entity": "department", "extra": {}},
    {"query": "departamentul cu cei mai multi angajati",
     "intent": "aggregate", "entity": "department", "extra": {"agg": "max_employees"}},
    {"query": "care departament are cei mai putini angajati",
     "intent": "aggregate", "entity": "department", "extra": {"agg": "min_employees"}},
    {"query": "distributia angajatilor pe departamente",
     "intent": "aggregate", "entity": "department", "extra": {"agg": "distribution"}},

    # ── salarii ──
    {"query": "salariul meu",
     "intent": "detail", "entity": "salary", "extra": {"personal": True}},
    {"query": "cat castig",
     "intent": "detail", "entity": "salary", "extra": {"personal": True}},
    {"query": "salariul mediu in firma",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "avg_company"}},
    {"query": "salariul mediu pe departamente",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "avg_dept"}},
    {"query": "cel mai mare salariu din firma",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max"}},
    {"query": "cel mai mic salariu",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "min"}},

    # ── proiecte ──
    {"query": "proiectele active",
     "intent": "list", "entity": "project", "extra": {"status": "active"}},
    {"query": "care sunt proiectele in desfasurare",
     "intent": "list", "entity": "project", "extra": {"status": "active"}},
    {"query": "proiectele terminate",
     "intent": "list", "entity": "project", "extra": {"status": "inactive"}},
    {"query": "cate proiecte active exista",
     "intent": "count", "entity": "project", "extra": {"status": "active"}},
    {"query": "taskurile mele",
     "intent": "list", "entity": "task", "extra": {"personal": True}},
    {"query": "taskurile neterminate",
     "intent": "list", "entity": "task", "extra": {"status": "todo"}},
    {"query": "cate taskuri au fost completate saptamana trecuta",
     "intent": "count", "entity": "task",
     "extra": {"status": "done", "temporal": "last_week"}},

    # ── adeverinte ──
    {"query": "adeverintele in asteptare",
     "intent": "list", "entity": "certificate", "extra": {"status": 0}},
    {"query": "cate adeverinte sunt neaprobate",
     "intent": "count", "entity": "certificate", "extra": {"status": 0}},
    {"query": "adeverintele mele",
     "intent": "list", "entity": "certificate", "extra": {"personal": True}},

    # ── posturi ──
    {"query": "ce functii exista in firma",
     "intent": "list", "entity": "position", "extra": {}},
    {"query": "posturile disponibile",
     "intent": "list", "entity": "job_opening", "extra": {}},
    {"query": "tipurile de angajati din IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "salariile pozitiilor din IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "care sunt salariile functiilor din HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "ce salarii au pozitiile din firma",
     "intent": "list", "entity": "position", "extra": {}},
    # ── sărbători legale ──
    {"query": "sarbatorile legale din acest an",
     "intent": "list", "entity": "holiday", "extra": {"temporal": "this_year"}},
    {"query": "care sunt sarbatorile legale",
     "intent": "list", "entity": "holiday", "extra": {}},
    {"query": "sarbatorile ramase in acest an",
     "intent": "list", "entity": "holiday", "extra": {"temporal": "remaining"}},
    {"query": "zile libere legale ramase",
     "intent": "list", "entity": "holiday", "extra": {"temporal": "remaining"}},
    {"query": "cate sarbatori legale mai sunt",
     "intent": "count", "entity": "holiday", "extra": {"temporal": "remaining"}},
    {"query": "sarbatorile din luna aceasta",
     "intent": "list", "entity": "holiday", "extra": {}},
    {"query": "concedii de craciun",
     "intent": "list", "entity": "holiday", "extra": {}},
    # ── eligibilitate concediu ──
    {"query": "am voie sa iau concediu in perioada 15-20 august",
     "intent": "detail", "entity": "leave_eligibility", "extra": {"personal": True}},
    {"query": "pot sa iau concediu saptamana viitoare",
     "intent": "detail", "entity": "leave_eligibility", "extra": {"personal": True}},
    {"query": "pot lua concediu in august",
     "intent": "detail", "entity": "leave_eligibility", "extra": {"personal": True}},
    # ── top N angajați ──
    {"query": "top 5 angajati",
     "intent": "list", "entity": "employee", "extra": {}},
    {"query": "top 5 angajati hr",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "top 10 angajati it",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "primii 5 angajati din hr",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    # ── top N salarii ──
    {"query": "top 5 salarii",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max"}},
    {"query": "top 5 salarii finante",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max", "dept_hint": True}},
    {"query": "top 10 salarii it",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max", "dept_hint": True}},
    {"query": "cele mai mari 5 salarii",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max"}},
    # ── variante scurte/informale fără verb — utile pentru TF-IDF ──
    # Ex: "tipuri pozitii IT", "pozitii IT", "functii HR"
    {"query": "tipuri pozitii IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    # ── query-uri scurte angajați per departament ──
    {"query": "cati angajati it",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "cati angajati hr",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "cati angajati finante",
     "intent": "count", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "angajati it",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "angajati hr",
     "intent": "list", "entity": "employee", "extra": {"dept_hint": True}},
    {"query": "pozitii IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "pozitii HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "functii IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "functii HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "roluri din IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "roluri din HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "tipuri de posturi",
     "intent": "list", "entity": "position", "extra": {}},
    {"query": "pozitiile din firma",
     "intent": "list", "entity": "position", "extra": {}},
    {"query": "functiile din departamentul HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "ce pozitii sunt in IT",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},
    {"query": "ce pozitii sunt in HR",
     "intent": "list", "entity": "position", "extra": {"dept_hint": True}},

    # ── echipa mea ──
    {"query": "cine e in concediu din echipa mea saptamana asta",
     "intent": "list", "entity": "team_leave", "extra": {"personal": True}},
    {"query": "ce salarii au cei din echipa mea",
     "intent": "list", "entity": "team_salary", "extra": {"personal": True}},
    {"query": "cine are cel mai mare salariu din echipa mea",
     "intent": "aggregate", "entity": "team_salary", "extra": {"agg": "max", "personal": True}},
    {"query": "cine lucreaza in proiectul X",
     "intent": "list", "entity": "team_members", "extra": {}},
    {"query": "membrii echipei mele",
     "intent": "list", "entity": "team_members", "extra": {"personal": True}},

    # ── taskuri ──
    {"query": "taskuri care trebuie finalizate astazi",
     "intent": "list", "entity": "task", "extra": {"deadline": "today"}},
    {"query": "ce taskuri am pe ziua de azi",
     "intent": "list", "entity": "task", "extra": {"personal": True, "deadline": "today"}},
    {"query": "taskurile mele pentru proiectul X",
     "intent": "list", "entity": "task", "extra": {"personal": True}},
    {"query": "cate taskuri sunt in medie completate pe luna",
     "intent": "aggregate", "entity": "task_stats", "extra": {"agg": "avg_monthly"}},
    {"query": "cati angajati au mai putin de 2 taskuri realizate",
     "intent": "aggregate", "entity": "task_stats", "extra": {"agg": "low_performers"}},
    {"query": "ce departament are cel mai mare workload",
     "intent": "aggregate", "entity": "task_stats", "extra": {"agg": "workload_dept"}},

    # ── concediu personal avansat ──
    {"query": "cat concediu medical am avut anul asta",
     "intent": "detail", "entity": "leave_personal_stats", "extra": {"personal": True}},
    {"query": "cand este urmatorul meu concediu",
     "intent": "detail", "entity": "next_leave", "extra": {"personal": True}},
    {"query": "cate zile de concediu am in total",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True, "total": True}},
    {"query": "de cate ori pot sa imi iau concediu",
     "intent": "detail", "entity": "leave_balance", "extra": {"personal": True}},

    # ── vechime / angajări ──
    {"query": "de cat timp sunt in aceasta firma",
     "intent": "detail", "entity": "tenure", "extra": {"personal": True}},
    {"query": "angajati cu mai putin de 1 an vechime",
     "intent": "list", "entity": "employee", "extra": {"tenure_filter": "lt_1y"}},
    {"query": "angajati inceputi in ultimele 3 luni",
     "intent": "list", "entity": "employee", "extra": {"tenure_filter": "last_3m"}},
    {"query": "cate angajari s-au facut in ultima luna",
     "intent": "count", "entity": "hiring_stats", "extra": {"period": "last_month"}},
    {"query": "cate angajari s-au facut in ultimul an",
     "intent": "count", "entity": "hiring_stats", "extra": {"period": "last_year"}},
    {"query": "cati angajati au fost concediati luna asta",
     "intent": "count", "entity": "termination_stats", "extra": {}},

    # ── salarii avansate ──
    {"query": "care este salariul minim pentru pozitia mea",
     "intent": "detail", "entity": "position_salary", "extra": {"personal": True, "agg": "min"}},
    {"query": "care este salariul maxim pentru pozitia mea",
     "intent": "detail", "entity": "position_salary", "extra": {"personal": True, "agg": "max"}},
    {"query": "care este salariul mediu pentru pozitia mea",
     "intent": "detail", "entity": "position_salary", "extra": {"personal": True, "agg": "avg"}},
    {"query": "care departamente sunt mai bine platite",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "avg_dept"}},
    {"query": "in care departament au angajatii cel mai mare salariu",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max_dept"}},
    {"query": "cel mai bun platit post in departamentul IT",
     "intent": "aggregate", "entity": "position", "extra": {"dept_hint": True, "agg": "max_salary"}},
    {"query": "care este salariul mediu pentru pozitia de manager",
     "intent": "detail", "entity": "position_salary", "extra": {}},
    {"query": "angajati pe aceeasi pozitie ca mine cu salariu mai mare",
     "intent": "list", "entity": "salary_comparison", "extra": {"personal": True}},
    {"query": "cel mai mare salariu angajati angajati dupa 2020",
     "intent": "aggregate", "entity": "salary", "extra": {"agg": "max"}},

    # ── structură organizațională ──
    {"query": "cine este managerul meu",
     "intent": "detail", "entity": "my_manager", "extra": {"personal": True}},
    {"query": "angajatii seniori",
     "intent": "list", "entity": "senior_employees", "extra": {}},
    {"query": "angajatii cu aceeasi pozitie ca mine",
     "intent": "list", "entity": "same_position", "extra": {"personal": True}},
    {"query": "cati angajati nu au niciun subaltern",
     "intent": "count", "entity": "no_subordinates", "extra": {}},
    {"query": "cine are cea mai mare vechime in companie",
     "intent": "detail", "entity": "tenure", "extra": {"agg": "max"}},
    {"query": "numar promovari in departamentul IT",
     "intent": "count", "entity": "promotions", "extra": {"dept_hint": True}},
    {"query": "cate angajari sau facut in ultimul an",
     "intent": "count", "entity": "hiring_stats", "extra": {"period": "last_year"}},
    # ── fluturaș / deduceri salariu ──
    {"query": "care sunt deducerile din salariul meu",
     "intent": "detail", "entity": "salary_deductions", "extra": {"personal": True}},
    {"query": "cat platesc taxe din salariu",
     "intent": "detail", "entity": "salary_deductions", "extra": {"personal": True}},
    {"query": "ce retineri am pe salariu",
     "intent": "detail", "entity": "salary_deductions", "extra": {"personal": True}},
    {"query": "salariul meu net si brut",
     "intent": "detail", "entity": "salary_deductions", "extra": {"personal": True}},
    {"query": "ce salariu au angajatii in medie brut si net",
     "intent": "aggregate", "entity": "salary_avg_net", "extra": {}},
    {"query": "salariu mediu brut si net in firma",
     "intent": "aggregate", "entity": "salary_avg_net", "extra": {}},
    {"query": "salariul mediu net al angajatilor",
     "intent": "aggregate", "entity": "salary_avg_net", "extra": {}},

    # ── misc ──
    {"query": "cat mai am pana se termina programul",
     "intent": "detail", "entity": "work_hours_left", "extra": {}},
    {"query": "in ultimii 3 ani in ce luna si-au luat angajatii cele mai multe zile de concediu",
     "intent": "aggregate", "entity": "leave_analytics", "extra": {}},
    {"query": "cati angajati lucreaza remote",
     "intent": "count", "entity": "remote_employees", "extra": {}},
]


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 2 — NORMALIZARE
# ══════════════════════════════════════════════════════════════════════════════

def normalize(text: str) -> str:
    text = text.lower().strip()
    for char, repl in [('ă','a'),('â','a'),('î','i'),('ș','s'),('ş','s'),('ț','t'),('ţ','t')]:
        text = text.replace(char, repl)
    text = re.sub(r'[^\w\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 3 — ENTITĂȚI DETECTABILE
# ══════════════════════════════════════════════════════════════════════════════

# Mapare departamente: orice variantă → canonical
DEPARTMENT_MAP = {
    'it': 'IT', 'informatica': 'IT', 'tehnologie': 'IT',
    'software': 'IT', 'programare': 'IT', 'tehnic': 'IT',
    'calculatoare': 'IT', 'tech': 'IT',
    'hr': 'HR', 'resurse umane': 'HR', 'human resources': 'HR',
    'personal': 'HR', 'recrutare': 'HR',
    'finante': 'Finante', 'financiar': 'Finante', 'contabilitate': 'Finante',
    'financiara': 'Finante', 'finance': 'Finante', 'economic': 'Finante',
    'management': 'Management', 'conducere': 'Management', 'directie': 'Management',
    'marketing': 'Marketing', 'publicitate': 'Marketing', 'vanzari': 'Marketing',
    'juridic': 'Juridic', 'legal': 'Juridic', 'drept': 'Juridic',
    'logistica': 'Logistica', 'distributie': 'Logistica', 'transport': 'Logistica',
}

# Mapare expresii temporale → (clauza SQL, eticheta)
TEMPORAL_MAP = {
    'astazi':            ("CURDATE() BETWEEN c.start_c AND c.end_c",                                  "astăzi"),
    'azi':               ("CURDATE() BETWEEN c.start_c AND c.end_c",                                  "astăzi"),
    'planificate':       ("c.start_c >= CURDATE()",                                                    "planificate (viitoare)"),
    'viitoare':          ("c.start_c >= CURDATE()",                                                    "viitoare"),
    'urmatoare':         ("c.start_c >= CURDATE()",                                                    "următoarele"),
    'luna aceasta':      ("MONTH(c.start_c)=MONTH(CURDATE()) AND YEAR(c.start_c)=YEAR(CURDATE())",    "luna aceasta"),
    'luna curenta':      ("MONTH(c.start_c)=MONTH(CURDATE()) AND YEAR(c.start_c)=YEAR(CURDATE())",    "luna aceasta"),
    'luna trecuta':      ("MONTH(c.start_c)=MONTH(CURDATE()-INTERVAL 1 MONTH) AND YEAR(c.start_c)=YEAR(CURDATE()-INTERVAL 1 MONTH)", "luna trecută"),
    'luna viitoare':     ("MONTH(c.start_c)=MONTH(CURDATE()+INTERVAL 1 MONTH)",                       "luna viitoare"),
    'anul acesta':       ("YEAR(c.start_c)=YEAR(CURDATE())",                                          "anul acesta"),
    'anul trecut':       ("YEAR(c.start_c)=YEAR(CURDATE())-1",                                        "anul trecut"),
    'saptamana trecuta': ("YEARWEEK(c.start_c)=YEARWEEK(CURDATE()-INTERVAL 1 WEEK)",                  "săptămâna trecută"),
    'saptamana aceasta': ("YEARWEEK(c.start_c)=YEARWEEK(CURDATE())",                                  "săptămâna aceasta"),
}

LEAVE_STATUS_MAP = {
    'aprobat director': (2,  "aprobat director"),
    'aprobat sef':      (1,  "aprobat șef"),
    'aprobate':         (2,  "aprobate"),
    'aprobat':          (2,  "aprobat"),
    'in asteptare':     (0,  "în așteptare"),
    'asteptare':        (0,  "în așteptare"),
    'neaprobat':        (0,  "neaprobat"),
    'pending':          (0,  "pending"),
    'respinse':         (-1, "respinse"),
    'respins':          (-1, "respins"),
    'refuzat':          (-1, "refuzat"),
}

CERT_STATUS_MAP = {
    'in asteptare': (0,  "în așteptare"),
    'asteptare':    (0,  "în așteptare"),
    'neaprobate':   (0,  "neaprobate"),
    'neaprobat':    (0,  "neaprobat"),
    'aprobate':     (2,  "aprobate"),
    'aprobat':      (2,  "aprobat"),
    'respinse':     (-1, "respinse"),
    'respins':      (-1, "respins"),
}


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 3b — ANALIZOR CUVINTE INTEROGATIVE
#
# Română are mai multe cuvinte interogative și fiecare implică un tip diferit
# de răspuns. Le analizăm ca strat separat, înainte de TF-IDF matcher.
#
# Logică:
#   câți/câte          → intent forțat COUNT
#   cine               → subiect este întotdeauna persoană/angajat
#   care + context     → depinde de ce urmează după "care":
#       care angajat   → persoană
#       care dept      → departament
#       care salariu   → detaliu salariu
#       care vechime   → detaliu vechime/senioritate
#       care pozitie/rol/rang/titlu → detaliu poziție
#   ce                 → context variabil, mai slab decât "care"
#   pozitie/rol/rang   → entitate poziție — se uită la tipuri.ierarhie
# ══════════════════════════════════════════════════════════════════════════════

# Grupuri de cuvinte cheie pentru fiecare dimensiune semantică
_PERSON_NOUNS = {
    'angajat', 'angajati', 'angajata', 'persoana', 'persoane', 'om', 'oameni',
    'salariat', 'salariate', 'coleg', 'colegi', 'lucrator', 'lucratori',
    'colaborator', 'colaboratori', 'membru', 'membrii', 'membrul',
    'staff', 'personal',
}

_DEPT_NOUNS = {
    'departament', 'departamente', 'departamentul', 'sectie', 'sectii',
    'divizie', 'divizii', 'echipa', 'echipe', 'grup', 'grupuri',
    'biroul', 'compartiment',
}

_SALARY_NOUNS = {
    # forme de bază
    'salariu', 'salariul', 'salarii', 'salariile', 'salariilor', 'salariului',
    # sinonime + forme flexionate
    'leafă', 'leafa', 'remuneratie', 'remuneratia', 'remuneratiei',
    'remunerația', 'castig', 'castigul', 'castiguri', 'castigurile',
    'venit', 'venitul', 'venituri', 'veniturile',
    'compensatie', 'compensatia', 'net', 'brut', 'retributie',
}

_TENURE_NOUNS = {
    'vechime', 'vechimea', 'senioritate', 'seniority', 'experienta', 'experiența',
    'data angajarii', 'data angajarii', 'de cand lucreaza', 'de cand este',
    'cat timp lucreaza', 'cat timp a lucrat', 'ani de munca', 'ani lucrati',
}

_POSITION_NOUNS = {
    # pozitie — toate formele: nominativ, genitiv, plural, articulat
    'pozitie', 'pozitia', 'pozitiei', 'pozitii', 'pozitiile', 'pozitiilor',
    # rol
    'rol', 'rolul', 'rolului', 'roluri', 'rolurile', 'rolurilor',
    # rang
    'rang', 'rangul', 'rangului', 'ranguri', 'rangurile', 'rangurilor', 'rank',
    # titlu
    'titlu', 'titlul', 'titlului', 'titulatura', 'titulatură',
    # functie
    'functie', 'functia', 'functiei', 'functii', 'functiile', 'functiilor',
    # grad / nivel
    'grad', 'gradul', 'gradului', 'nivel', 'nivelul', 'nivelului',
    # ierarhie / post
    'ierarhie', 'ierarhia', 'post', 'postul', 'postului', 'posturi', 'posturilor',
    # tip angajat
    'tip angajat', 'tipul angajatului',
}

# Cuvinte interogative principale
_CATI  = {'cati', 'cate', 'cat', 'cata', 'numarul', 'numar', 'total', 'suma'}
_CINE  = {'cine', 'cin'}
_CARE  = {'care', 'care este', 'care e', 'care sunt', 'ce este', 'ce e'}
_CE    = {'ce', 'care'}


@dataclass
class QuestionAnalysis:
    """
    Rezultatul analizei cuvântului interogativ.

    question_word : cuvântul detectat ("câți", "cine", "care", etc.)
    forced_intent : dacă cuvântul forțează un anumit intent
                    ("câți" → "count" indiferent de ce urmează)
    forced_entity : dacă cuvântul + contextul forțează o anumită entitate
                    ("cine" → "employee", "care salariu" → "salary")
    focus         : ce dimensiune e în focarul întrebării
                    ("persoana", "departament", "salariu", "vechime", "pozitie")
    confidence    : cât de siguri suntem de detecție (0.0–1.0)
    reason        : explicație human-readable
    """
    question_word:  Optional[str] = None
    forced_intent:  Optional[str] = None   # "count" | "list" | "detail" | None
    forced_entity:  Optional[str] = None   # entitate forțată sau None
    focus:          Optional[str] = None   # "persoana" | "dept" | "salariu" | "vechime" | "pozitie"
    confidence:     float = 0.0
    reason:         str = ""


def analyze_question_word(query_norm: str) -> QuestionAnalysis:
    """
    Analizează cuvântul interogativ din query și deduce intenția și focarul.

    Exemple:
      "câți angajați sunt în IT"      → forced_intent=count, focus=persoana
      "cine este în concediu"         → forced_entity=employee, focus=persoana
      "care este salariul lui Vasile" → forced_entity=salary, focus=salariu
      "care este vechimea mea"        → forced_entity=tenure, focus=vechime
      "care este rolul lui"           → forced_entity=position, focus=pozitie
      "care departament are mai mulți"→ forced_entity=department, focus=dept
      "ce funcții există în HR"       → forced_entity=position, focus=pozitie
    """
    qa = QuestionAnalysis()
    tokens = set(query_norm.split())

    # ── câți/câte → COUNT forțat ──────────────────────────────────────────────
    if tokens & _CATI:
        matched = list(tokens & _CATI)[0]
        qa.question_word = matched
        qa.forced_intent = 'count'
        qa.confidence    = 0.95
        qa.reason        = f"'{matched}' → intenție COUNT forțată"

        # Prioritate entitate în _CATI:
        # ─ leave_balance înainte de leave
        # ─ PERSON înainte de DEPT — "câți angajați din departamentul HR?"
        #   are _DEPT_NOUNS ('departamentul') DAR entitatea numărată e EMPLOYEE.
        #   'departamentul' e filtru, nu entitate. _PERSON_NOUNS câștigă.
        # ─ DEPT singur (fără PERSON) → numărăm departamente
        _balance_hints = ['disponibile', 'ramase', 'ramas', 'mai am', 'mai ai',
                          'imi mai raman', 'imi mai revin', 'am ramas',
                          'zile libere mai', 'cate zile mai']
        has_balance = any(h in query_norm for h in _balance_hints)
        has_leave   = any(w in query_norm for w in ['concediu', 'concedii', 'zile'])

        if has_leave and has_balance:
            qa.focus         = 'concediu'
            qa.forced_entity = 'leave_balance'
        elif has_leave:
            qa.focus         = 'concediu'
            qa.forced_entity = 'leave'
        elif any(w in query_norm for w in ['adeverinta', 'adeverinte']):
            qa.focus         = 'adeverinta'
            qa.forced_entity = 'certificate'
        elif any(w in query_norm for w in ['proiect', 'proiecte']):
            qa.focus         = 'proiect'
            qa.forced_entity = 'project'
        elif any(w in query_norm for w in ['task', 'taskuri', 'sarcina']):
            qa.focus         = 'task'
            qa.forced_entity = 'task'
        elif tokens & _PERSON_NOUNS:
            # ÎNAINTE de _DEPT_NOUNS — "câți angajați din departament" numără oameni
            qa.focus         = 'persoana'
            qa.forced_entity = 'employee'
        elif tokens & _DEPT_NOUNS and not (tokens & _PERSON_NOUNS):
            # Doar dacă NU avem person nouns → numărăm departamente
            qa.focus         = 'dept'
            qa.forced_entity = 'department'
        return qa

    # ── cine → persoană forțată ───────────────────────────────────────────────
    # "Cine" întreabă mereu despre o persoană. Fără excepție în română.
    if tokens & _CINE:
        qa.question_word = 'cine'
        qa.forced_intent = 'list'
        qa.focus         = 'persoana'
        qa.confidence    = 0.98

        # "cine" întreabă mereu despre o persoană, DAR entitatea SQL
        # depinde de CONTEXT — ce face acea persoană / unde se află.
        #
        #  "cine este în concediu astăzi?"  → tabela concedii  (nu useri!)
        #      → _build_leave returnează angajat+dept+tip+status+date
        #      → filtrul temporal 'astăzi' e aplicat corect
        #
        #  "cine a cerut o adeverință?"     → tabela adeverinte
        #
        #  "cine lucrează la proiectul X?"  → tabela tasks/proiecte
        #
        #  "cine lucrează în IT?"           → tabela useri (employee, default)
        #
        # Fără această logică, toate interogările "cine" mergeau pe _build_employee
        # și ignorau complet tabela concedii / adeverinte / tasks.

        if any(w in query_norm for w in ['concediu', 'concedii', 'concediile']):
            qa.forced_entity = 'leave'
            qa.reason        = ("'cine' + 'concediu' → query pe tabela concedii, "
                                "nu useri (returnează cine e în concediu, cu filtre temporale)")

        elif any(w in query_norm for w in ['adeverinta', 'adeverinte', 'adeverintele']):
            qa.forced_entity = 'certificate'
            qa.reason        = "'cine' + 'adeverinta' → query pe tabela adeverinte"

        elif any(w in query_norm for w in ['task', 'taskuri', 'sarcina', 'sarcini']):
            qa.forced_entity = 'task'
            qa.reason        = "'cine' + 'task' → query pe tabela tasks"

        elif any(w in query_norm for w in ['proiect', 'proiecte']):
            qa.forced_entity = 'project'
            qa.reason        = "'cine' + 'proiect' → query pe tabela proiecte"

        else:
            # Default: persoana / angajat — "cine lucrează în IT?", "cine e managerul?"
            qa.forced_entity = 'employee'
            qa.reason        = "'cine' fără context specific → subiect=angajat (tabela useri)"

        return qa

    # ── care/ce → analiză context ─────────────────────────────────────────────
    # "Care" e ambiguu — trebuie să ne uităm la ce urmează.
    has_care = any(expr in query_norm for expr in ['care este', 'care e ',
                                                    'care sunt', 'care '])
    has_ce   = query_norm.startswith('ce ') or ' ce ' in query_norm

    if has_care or has_ce:
        qa.question_word = 'care' if has_care else 'ce'

        # Prioritate 1: "care este salariul/venitul/câștigul" → salary detail
        # EXCEPȚIE: dacă există și noun de poziție (ex: "salariile pozițiilor"),
        # înseamnă că userul vrea lista de poziții cu salarii → câștigă poziția (prio 3)
        # _build_position() include oricum t.salariu în SELECT
        has_salary   = bool(tokens & _SALARY_NOUNS)
        has_position = bool(tokens & _POSITION_NOUNS)

        if has_salary and not has_position:
            qa.forced_entity = 'salary'
            qa.focus         = 'salariu'
            qa.confidence    = 0.92

            # Detectăm tipul de query salarial din cuvintele cheie:
            #
            #   "salariul meu / cat câștig / salariul lui X"
            #       → detail (salariul unui anumit angajat)
            #
            #   "salariul mediu / media salariilor / salariu minim / maxim"
            #       → aggregate (statistici la nivel de firmă sau departament)
            #
            # Fără această distincție, "care este salariul mediu în firmă?"
            # era tratat ca detail și returna salariul userului curent (bug!)

            _agg_hints = ['mediu', 'medie', 'media', 'average', 'avg',
                          'maxim', 'maximum', 'cel mai mare', 'cel mai mic',
                          'minim', 'minimum', 'top', 'distribuiti', 'distributie',
                          'pe departamente', 'comparatie', 'comparativ']

            if any(h in query_norm for h in _agg_hints):
                qa.forced_intent = 'aggregate'
                qa.reason        = (f"'{qa.question_word}' + noun salarial + keyword agregare "
                                    f"({[h for h in _agg_hints if h in query_norm]}) "
                                    f"→ statistici salariale (nu detail personal)")
            else:
                qa.forced_intent = 'detail'
                qa.reason        = (f"'{qa.question_word}' + noun salarial "
                                    f"({tokens & _SALARY_NOUNS}) → detaliu salariu personal")
            return qa

        # Prioritate 2: "care este vechimea/experiența" → tenure detail
        if tokens & _TENURE_NOUNS or any(expr in query_norm for expr in _TENURE_NOUNS):
            qa.forced_entity = 'tenure'
            qa.forced_intent = 'detail'
            qa.focus         = 'vechime'
            qa.confidence    = 0.92
            qa.reason        = f"'{qa.question_word}' + noun vechime → detaliu vechime/senioritate"
            return qa

        # Prioritate 3: "care este poziția/rolul/rangul/funcția" → position
        # Captează și: "salariile pozițiilor" (salary+position → position câștigă)
        if has_position:
            # Dacă avem și salary nouns → e o cerere de tip "lista pozițiilor cu salarii"
            # intent=list e mai potrivit decât detail (vrem toate, nu una specifică)
            is_list_query = has_salary or any(
                w in query_norm for w in ['sunt', 'exista', 'lista', 'arata', 'toate']
            )
            qa.forced_entity = 'position'
            qa.forced_intent = 'list' if is_list_query else 'detail'
            qa.focus         = 'pozitie'
            qa.confidence    = 0.90
            if has_salary:
                qa.reason = (f"'{qa.question_word}' + salary+position nouns "
                             f"({tokens & _SALARY_NOUNS} + {tokens & _POSITION_NOUNS}) "
                             f"→ lista pozițiilor cu salarii (position câștigă)")
            else:
                qa.reason = (f"'{qa.question_word}' + noun poziție "
                             f"({tokens & _POSITION_NOUNS}) → detaliu poziție/rang")
            return qa

        # Prioritate 4: "care departament" → department
        if tokens & _DEPT_NOUNS:
            qa.forced_entity = 'department'
            qa.focus         = 'dept'
            qa.confidence    = 0.88
            _superlative_hints = ['multi', 'putini', 'mare', 'mic', 'maxim', 'minim',
                                  'cel mai', 'cei mai', 'max', 'min']
            if any(h in query_norm for h in _superlative_hints):
                qa.forced_intent = 'aggregate'
                qa.reason        = (f"'care' + departament + superlativ "
                                    f"({tokens & _DEPT_NOUNS}) → agregare departamente")
            else:
                qa.forced_intent = 'list'
                qa.reason        = (f"'{qa.question_word}' + noun departament "
                                    f"({tokens & _DEPT_NOUNS}) → entitate departament")
            return qa

        # Prioritate 5: "care angajat/persoană" → employee list
        if tokens & _PERSON_NOUNS:
            qa.forced_entity = 'employee'
            qa.forced_intent = 'list'
            qa.focus         = 'persoana'
            qa.confidence    = 0.88
            qa.reason        = (f"'{qa.question_word}' + noun persoană "
                                f"({tokens & _PERSON_NOUNS}) → entitate angajat")
            return qa

        # "care" fără context clar — înregistrăm dar nu forțăm nimic
        qa.confidence = 0.30
        qa.reason     = f"'{qa.question_word}' fără context nominal clar — lăsăm TF-IDF să decidă"
        return qa

    # ── salariu detectat independent (fără cuvânt interogativ) ──────────────
    # Ex: "top 5 salarii", "salarii finante", "salariile din IT"
    # ÎNAINTE de position — salary e mai specific ca entitate standalone
    sal_found = tokens & _SALARY_NOUNS
    if sal_found and not (tokens & _POSITION_NOUNS):
        qa.question_word = None
        qa.forced_entity = 'salary'
        qa.focus         = 'salariu'
        qa.confidence    = 0.78
        qa.reason        = f"noun salarial detectat fără interogativ ({sal_found}) → entitate salary"
        return qa

    # ── pozitie/rol/rang detectate independent (fără cuvânt interogativ) ──────
    # Ex: "pozițiile disponibile în IT", "rangul angajaților din HR"
    pos_found = tokens & _POSITION_NOUNS
    if pos_found:
        qa.question_word = None
        qa.forced_entity = 'position'
        qa.focus         = 'pozitie'
        qa.confidence    = 0.75
        qa.reason        = f"noun poziție detectat fără interogativ ({pos_found}) → entitate poziție"
        return qa

    # Niciun interogativ detectat — analizorul nu intervine
    qa.reason = "niciun cuvânt interogativ detectat"
    return qa


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 4 — STRUCTURA DE DEBUG + ExtractedEntities
# ══════════════════════════════════════════════════════════════════════════════

@dataclass
class BuildTrace:
    pieces: List[dict] = field(default_factory=list)

    def add(self, piece_type: str, sql_fragment: str, reason: str):
        self.pieces.append({
            'type':   piece_type,
            'sql':    sql_fragment.strip(),
            'reason': reason
        })

    def format(self) -> str:
        icons = {'BASE':'🔵','SELECT':'🟢','WHERE':'🟡',
                 'ORDER':'🟠','LIMIT':'🔴','NOTE':'⚪'}
        lines = ["\n┌─ CONSTRUCȚIE SQL ─────────────────────────────────────"]
        for p in self.pieces:
            icon = icons.get(p['type'], '▪')
            lines.append(f"│ {icon} [{p['type']:6}] {p['reason']}")
            if p['sql'] and p['type'] != 'NOTE':
                preview = p['sql'][:80] + ('...' if len(p['sql']) > 80 else '')
                lines.append(f"│          → {preview}")
        lines.append("└───────────────────────────────────────────────────────")
        return '\n'.join(lines)


@dataclass
class ExtractedEntities:
    """
    Toate entitățile detectate din query.
    Fiecare câmp corespunde unei dimensiuni semantice independente.
    Pot fi prezente simultan (ex: dept + temporal + status).
    """
    # ── entități clasice ──
    department:          Optional[str] = None
    temporal_sql:        Optional[str] = None
    temporal_label:      Optional[str] = None
    leave_status:        Optional[int] = None
    leave_status_label:  Optional[str] = None
    cert_status:         Optional[int] = None
    cert_status_label:   Optional[str] = None
    number:              Optional[int] = None
    is_personal:         bool = False

    # ── entități noi din QuestionWordAnalyzer ──
    question_word:       Optional[str] = None   # "câți", "cine", "care", "ce"
    focus:               Optional[str] = None   # "persoana"|"dept"|"salariu"|"vechime"|"pozitie"

    # override-uri de la analizorul de cuvinte interogative
    # dacă sunt setate, au prioritate față de ce zice TF-IDF matcher
    qw_forced_intent:    Optional[str] = None
    qw_forced_entity:    Optional[str] = None
    qw_confidence:       float = 0.0
    qw_reason:           str = ""

    # Agregare departamente — detectată din superlative, prioritate față de TF-IDF extra
    dept_agg:            Optional[str] = None   # 'max_employees'|'min_employees'|'distribution'
    # Locații departamente — True dacă query-ul vrea adresele din locatii_departamente
    dept_location:       bool = False
    # Agregare salarii — detectată din keywords ca 'mediu', 'maxim', 'pe departamente'
    salary_agg:          Optional[str] = None   # 'avg_company'|'avg_dept'|'max'|'min'

    # Top-N — când userul cere "top 5 ...", "primii 10 ..." → LIMIT explicit
    top_n:               Optional[int] = None

    # Tip concediu — filtru pe tipcon.motiv (medical, odihna, maternitate etc.)
    leave_type:          Optional[str] = None   # ex: 'medical', 'odihna', 'maternitate'

    # Grupare per persoană — "de persoană", "pe persoană", "per angajat"
    # → GROUP BY angajat cu SUM(durata) în loc de COUNT(*)
    group_by_person:     bool = False

    # Sărbători legale — interogare pe tabela sarbatori/libere
    is_holiday:          bool = False
    holiday_remaining:   bool = False

    # Eligibilitate concediu
    is_eligibility:      bool = False
    date_start:          Optional[str] = None
    date_end:            Optional[str] = None

    # Interogări echipă/personal avansate
    is_team_query:       bool = False
    project_name:        Optional[str] = None
    tenure_filter:       Optional[str] = None   # 'lt_1y'|'last_3m'|'last_6m'
    hiring_period:       Optional[str] = None   # 'last_month'|'last_year'|'last_3m'
    position_name:       Optional[str] = None   # "manager", "inginer" extras din query
    salary_agg_personal: Optional[str] = None   # 'min'|'max'|'avg' pt poziția mea
    deadline_today:      bool = False
    work_end_hour:       int  = 18

    def summary(self) -> str:
        found = []

        # Cuvânt interogativ
        if self.question_word:
            found.append(f"întrebat_cu='{self.question_word}'")
        if self.focus:
            found.append(f"focus='{self.focus}'")
        if self.qw_forced_intent:
            found.append(f"intent_fortat='{self.qw_forced_intent}' "
                         f"(conf={self.qw_confidence:.2f})")
        if self.qw_forced_entity:
            found.append(f"entitate_fortata='{self.qw_forced_entity}' "
                         f"(conf={self.qw_confidence:.2f})")

        # Entități clasice
        if self.department:
            found.append(f"departament='{self.department}'")
        if self.temporal_label:
            found.append(f"temporal='{self.temporal_label}'")
        if self.leave_status is not None:
            found.append(f"status_concediu={self.leave_status} ({self.leave_status_label})")
        if self.cert_status is not None:
            found.append(f"status_adeverinta={self.cert_status} ({self.cert_status_label})")
        if self.is_personal:
            found.append("personal=True")
        if self.number is not None:
            found.append(f"numar={self.number}")

        if not found:
            found.append("(nicio entitate specifică — query general)")
        return ', '.join(found)


def extract_entities(query_norm: str) -> ExtractedEntities:
    """
    Extrage toate entitățile detectabile din query-ul normalizat.

    Strategie în două straturi:
      1. QuestionWordAnalyzer — analizează interogativul și dă override-uri
         cu prioritate înaltă (câți → COUNT, cine → employee etc.)
      2. Detecție clasică — departament, temporal, status, număr, personal
         Se aplică indiferent de stratul 1 (pot coexista)
    """
    result = ExtractedEntities()

    # ── Stratul 1: analiză cuvânt interogativ ──
    qa = analyze_question_word(query_norm)
    result.question_word    = qa.question_word
    result.focus            = qa.focus
    result.qw_forced_intent = qa.forced_intent
    result.qw_forced_entity = qa.forced_entity
    result.qw_confidence    = qa.confidence
    result.qw_reason        = qa.reason

    # ── Stratul 2: detecție entități clasice ──

    # Personal
    personal_hints = ['eu ', 'meu', 'mea', 'mie', 'mine', 'proprii', 'propria', 'mele']
    if any(h in query_norm for h in personal_hints):
        result.is_personal = True

    # Departament — folosim word boundary (re.search cu \b) în loc de 'kw in string'
    # Motivul: substring match dă false positives:
    #   'it'  ⊂ 'pozitii'  → detecta departament='IT' din "ce tipuri de pozitii exista"
    #   'hr'  ⊂ 'thrilling' → ar detecta HR din texte englezești
    #   'tech' ⊂ 'tehnica'  → etc.
    # \b asigură că 'it' matchează doar ca cuvânt întreg, nu ca parte din alt cuvânt.
    for kw, canonical in sorted(DEPARTMENT_MAP.items(), key=lambda x: -len(x[0])):
        pattern = r'\b' + re.escape(kw) + r'\b'
        if re.search(pattern, query_norm):
            result.department = canonical
            break

    # Temporal (expresii lungi primele)
    for expr, (sql, label) in sorted(TEMPORAL_MAP.items(), key=lambda x: -len(x[0])):
        if expr in query_norm:
            result.temporal_sql   = sql
            result.temporal_label = label
            break

    # Status concedii
    for kw, (val, label) in sorted(LEAVE_STATUS_MAP.items(), key=lambda x: -len(x[0])):
        if kw in query_norm:
            result.leave_status       = val
            result.leave_status_label = label
            break

    # Status adeverinte
    for kw, (val, label) in sorted(CERT_STATUS_MAP.items(), key=lambda x: -len(x[0])):
        if kw in query_norm:
            result.cert_status       = val
            result.cert_status_label = label
            break

    # Număr explicit
    nums = re.findall(r'\b(\d+)\b', query_norm)
    if nums:
        result.number = int(nums[0])

    # ── Locații departamente ──────────────────────────────────────────────────
    _location_hints = ['locatie', 'locatii', 'locatia', 'adresa', 'adrese',
                       'sediu', 'sedii', 'unde se afla', 'unde este',
                       'strada', 'oras', 'judet']
    if any(h in query_norm for h in _location_hints):
        result.dept_location = True

    # ── Agregare departamente — superlative ───────────────────────────────────
    _max_hints  = ['multi', 'mare', 'mult', 'maxim', 'maximum', 'max',
                   'cel mai mare', 'cei mai multi']
    _min_hints  = ['putini', 'mic', 'minim', 'minimum', 'min',
                   'cel mai mic', 'cei mai putini', 'mai putini']
    _dist_hints = ['distributie', 'toti', 'toate', 'fiecare',
                   'per departament', 'pe departamente']
    if any(h in query_norm for h in _max_hints):
        result.dept_agg = 'max_employees'
    elif any(h in query_norm for h in _min_hints):
        result.dept_agg = 'min_employees'
    elif any(h in query_norm for h in _dist_hints):
        result.dept_agg = 'distribution'

    # ── Top-N ────────────────────────────────────────────────────────────────
    # "top 5 angajati", "primii 10 salarii", "top 3 proiecte"
    # Extragem numărul din construcțiile "top N" sau "primii N"
    top_match = re.search(r'\b(?:top|primii|primele|primii)\s+(\d+)\b', query_norm)
    if top_match:
        result.top_n = int(top_match.group(1))
    elif result.number and any(w in query_norm for w in ['top', 'primii', 'primele', 'cei mai']):
        result.top_n = result.number  # "cele mai mari 5 salarii" → top_n=5

    # ── Tip concediu ─────────────────────────────────────────────────────────
    # Filtrăm pe tipcon.motiv — tipurile de concediu din baza de date
    _leave_type_map = {
        'medical':     ['medical', 'boala', 'bolnav', 'incapacitate', 'sick'],
        'odihna':      ['odihna', 'odihn', 'vacanta', 'recreere', 'relaxare'],
        'maternitate': ['maternitate', 'matern', 'prenatal', 'postnatal', 'sarcina'],
        'paternitate': ['paternitate', 'patern'],
        'studii':      ['studii', 'examen', 'scoala', 'cursuri'],
        'deces':       ['deces', 'inmormantare', 'funeralii', 'doliu'],
    }
    for ltype, keywords in _leave_type_map.items():
        if any(kw in query_norm for kw in keywords):
            result.leave_type = ltype
            break

    # ── Grupare per persoană ──────────────────────────────────────────────────
    # "câte zile de persoană", "per angajat", "fiecare angajat" → GROUP BY + SUM
    _group_hints = ['de persoana', 'pe persoana', 'per persoana', 'per angajat',
                    'fiecare angajat', 'fiecare persoana', 'pe angajat',
                    'pe fiecare', 'individual', 'pentru fiecare']
    if any(h in query_norm for h in _group_hints):
        result.group_by_person = True

    # ── Eligibilitate concediu ────────────────────────────────────────────────
    # "am voie să-mi iau concediu", "pot lua concediu", "pot să iau concediu"
    # "îmi pot lua concediu", "mă pot odihni", "pot face concediu"
    _eligibility_hints = ['am voie', 'pot sa iau', 'pot lua', 'pot sa-mi iau',
                          'pot face', 'imi pot lua', 'am dreptul', 'am dreptul sa',
                          'este posibil', 'e posibil', 'pot cere concediu',
                          'pot depune cerere']
    if any(h in query_norm for h in _eligibility_hints):
        result.is_eligibility = True

        # Detectăm intervalul de date din query
        # Formate acceptate:
        #   "15-20 august" → 15/aug și 20/aug din anul curent
        #   "15 august - 20 august"
        #   "15 august pana pe 20 august"
        _MONTHS = {
            'ianuarie':1, 'ian':1, 'february':2,
            'februarie':2, 'feb':2,
            'martie':3, 'mar':3,
            'aprilie':4, 'apr':4,
            'mai':5,
            'iunie':6, 'iun':6,
            'iulie':7, 'iul':7,
            'august':8, 'aug':8,
            'septembrie':9, 'sep':9, 'sept':9,
            'octombrie':10, 'oct':10,
            'noiembrie':11, 'noi':11, 'nov':11,
            'decembrie':12, 'dec':12,
        }
        from datetime import datetime as _dt
        year = _dt.now().year

        # Pattern: "15-20 august" sau "15 - 20 august"
        m = re.search(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s+(' + '|'.join(_MONTHS.keys()) + r')', query_norm)
        if m:
            d1, d2, mon_str = int(m.group(1)), int(m.group(2)), m.group(3)
            mon = _MONTHS.get(mon_str, 1)
            result.date_start = f"{year}-{mon:02d}-{d1:02d}"
            result.date_end   = f"{year}-{mon:02d}-{d2:02d}"
        else:
            # Pattern: "15 august pana pe 20 august" sau "15 august - 20 august"
            m2 = re.search(
                r'(\d{1,2})\s+(' + '|'.join(_MONTHS.keys()) + r')'
                r'(?:\s*[-–]\s*|\s+pana\s+(?:pe|la|in)?\s*)'
                r'(\d{1,2})\s+(' + '|'.join(_MONTHS.keys()) + r')',
                query_norm
            )
            if m2:
                d1, mon1_str = int(m2.group(1)), m2.group(2)
                d2, mon2_str = int(m2.group(3)), m2.group(4)
                result.date_start = f"{year}-{_MONTHS[mon1_str]:02d}-{d1:02d}"
                result.date_end   = f"{year}-{_MONTHS[mon2_str]:02d}-{d2:02d}"

    # ── Interogări echipă ─────────────────────────────────────────────────────
    _team_hints = ['echipa mea', 'echipei mele', 'colegii mei', 'din echipa mea',
                   'membrii echipei', 'din echipa']
    if any(h in query_norm for h in _team_hints):
        result.is_team_query = True

    # ── Deadline astăzi (pentru taskuri) ──────────────────────────────────────
    if any(w in query_norm for w in ['astazi', 'azi', 'today', 'pe ziua de azi']):
        result.deadline_today = True

    # ── Filtru vechime angajat ────────────────────────────────────────────────
    if any(w in query_norm for w in ['mai putin de 1 an', 'sub 1 an', 'sub un an', 'mai putin de un an']):
        result.tenure_filter = 'lt_1y'
    elif any(w in query_norm for w in ['ultimele 3 luni', 'ultimii 3 luni', 'ultim 3 luni']):
        result.tenure_filter = 'last_3m'
    elif any(w in query_norm for w in ['ultimele 6 luni', 'ultimii 6 luni']):
        result.tenure_filter = 'last_6m'

    # ── Perioadă de angajare ──────────────────────────────────────────────────
    if any(w in query_norm for w in ['ultima luna', 'in ultima luna', 'luna trecuta']):
        result.hiring_period = 'last_month'
    elif any(w in query_norm for w in ['ultimul an', 'in ultimul an', 'anul trecut']):
        result.hiring_period = 'last_year'
    elif any(w in query_norm for w in ['ultimii 3 ani', 'ultimele 3 ani', 'ultim 3 ani']):
        result.hiring_period = 'last_3y'

    # ── Salariu per poziție mea (min/max/avg) ─────────────────────────────────
    if 'pozitia mea' in query_norm or 'functia mea' in query_norm or 'rolul meu' in query_norm:
        if any(w in query_norm for w in ['minim', 'cel mai mic', 'min']):
            result.salary_agg_personal = 'min'
        elif any(w in query_norm for w in ['maxim', 'cel mai mare', 'max']):
            result.salary_agg_personal = 'max'
        else:
            result.salary_agg_personal = 'avg'

    # ── Sărbători legale ──────────────────────────────────────────────────────
    _holiday_hints = ['sarbatoare', 'sarbatori', 'sarbatorile', 'sarbatorilor',
                      'zi libera legala', 'zile libere legale', 'libere legale',
                      'legal', 'legale', 'nationale', 'nationale',
                      'craciun', 'paste', 'revelion', 'ziua muncii', 'ziua nationala',
                      '1 mai', '1 decembrie', '8 martie', 'mica unire', 'mare unire']
    if any(h in query_norm for h in _holiday_hints):
        result.is_holiday = True
        # "rămase" → doar sărbătorile viitoare din an
        if any(w in query_norm for w in ['ramase', 'ramas', 'viitoare', 'mai sunt', 'mai avem']):
            result.holiday_remaining = True

    # ── Agregare salarii ──────────────────────────────────────────────────────
    # Detectăm tipul de agregare salarială direct din query,
    # independent de ce zice TF-IDF în extra['agg'].
    # Asta rezolvă cazuri ca "care este salariul mediu în firmă?" unde
    # QuestionWordAnalyzer forțează entity=salary dar nu știe ce tip de agg vrem.
    _sal_avg_dept  = ['pe departamente', 'per departament', 'pe fiecare departament',
                      'mediu pe dep', 'medie pe dep']
    _sal_avg_comp  = ['mediu', 'medie', 'media', 'average', 'avg',
                      'salariul mediu', 'salariile medii']
    _sal_max       = ['cel mai mare salariu', 'cel mai mare', 'maxim', 'maximum',
                      'max', 'top salarii', 'top 5']
    _sal_min       = ['cel mai mic salariu', 'cel mai mic', 'minim', 'minimum', 'min']

    if any(h in query_norm for h in _sal_avg_dept):
        result.salary_agg = 'avg_dept'
    elif any(h in query_norm for h in _sal_max):
        result.salary_agg = 'max'
    elif any(h in query_norm for h in _sal_min):
        result.salary_agg = 'min'
    elif any(h in query_norm for h in _sal_avg_comp):
        result.salary_agg = 'avg_company'

    return result


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 5 — QUERY BUILDER
#
# Inima sistemului v2.
# În loc de template-uri fixe, fiecare metodă _build_X() construiește
# query-ul din piese independente, adăugând la trace motivul fiecărei piese.
# ══════════════════════════════════════════════════════════════════════════════

class QueryBuilder:
    """
    Construiește SQL dinamic combinând piese în funcție de ce entități s-au găsit.

    Principiu:
      1. Alege BASE (FROM + JOINs necesare pentru entitate)
      2. Alege COLOANE (COUNT vs lista de câmpuri, în funcție de intent)
      3. Adaugă filtre WHERE doar dacă entitatea corespunzătoare a fost detectată
      4. Adaugă ORDER BY și LIMIT
      5. La fiecare pas, înregistrează în trace de ce s-a adăugat piesa
    """

    def build(self, intent: str, entity: str,
              ents: ExtractedEntities, extra: dict,
              user_id: Optional[int]) -> tuple:
        """
        Returns:
            (sql_string, BuildTrace)
        """
        trace = BuildTrace()

        # Dispatch la metoda corespunzătoare entității
        builders = {
            'employee':           self._build_employee,
            'leave':              self._build_leave,
            'leave_balance':      self._build_leave_balance,
            'department':         self._build_department,
            'salary':             self._build_salary,
            'project':            self._build_project,
            'task':               self._build_task,
            'certificate':        self._build_certificate,
            'position':           self._build_position,
            'job_opening':        self._build_job_opening,
            'tenure':             self._build_tenure,
            'holiday':            self._build_holiday,
            'leave_eligibility':  self._build_leave_eligibility,
            # ── entități noi ──
            'team_leave':         self._build_team_leave,
            'team_salary':        self._build_team_salary,
            'team_members':       self._build_team_members,
            'task_stats':         self._build_task_stats,
            'leave_personal_stats': self._build_leave_personal_stats,
            'next_leave':         self._build_next_leave,
            'hiring_stats':       self._build_hiring_stats,
            'termination_stats':  self._build_termination_stats,
            'position_salary':    self._build_position_salary,
            'salary_comparison':  self._build_salary_comparison,
            'my_manager':         self._build_my_manager,
            'senior_employees':   self._build_senior_employees,
            'same_position':      self._build_same_position,
            'no_subordinates':    self._build_no_subordinates,
            'promotions':         self._build_promotions,
            'work_hours_left':    self._build_work_hours_left,
            'leave_analytics':    self._build_leave_analytics,
            'remote_employees':   self._build_remote_employees,
            'salary_deductions':  self._build_salary_deductions,
            'salary_avg_net':     self._build_salary_avg_net,
        }

        builder = builders.get(entity)
        if not builder:
            trace.add('NOTE', '', f'Entitate necunoscută: {entity}')
            return None, trace

        sql = builder(intent, ents, extra, user_id, trace)
        return sql, trace

    # ────────────────────────────────────────────────────────── ANGAJAȚI ──────

    def _build_employee(self, intent, ents, extra, user_id, trace):
        wheres = ["u.username != 'test'"]
        trace.add('WHERE', "u.username != 'test' ",
                  'excludem userul de sistem și angajații inactivi')

        if ents.department:
            clause = f"UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
            wheres.append(clause)
            trace.add('WHERE', clause, f"departament detectat: '{ents.department}'")
        else:
            trace.add('NOTE', '', 'niciun departament → toată firma')

        where_str = "WHERE " + " AND ".join(wheres)

        if intent == 'count':
            # Pentru COUNT nu avem nevoie de denumiri_pozitii (INNER JOIN ar exclude angajații
            # care nu au intrare în acea tabelă, dând rezultate greșite)
            base_count = ("FROM useri u "
                          "LEFT JOIN departament d ON u.id_dep = d.id_dep")
            trace.add('BASE', base_count,
                      'COUNT: doar useri + departament (fără JOIN pe denumiri_pozitii)')
            select = "SELECT COUNT(*) AS total_angajati"
            trace.add('SELECT', select, 'intent=count → numărăm angajații activi')
            return f"{select}\n{base_count}\n{where_str}"

        else:
            # Pentru LIST avem nevoie de funcție și denumire completă
            base_list = ("FROM useri u "
                         "LEFT JOIN departament d ON u.id_dep = d.id_dep "
                         "LEFT JOIN tipuri t ON u.tip = t.tip "
                         "LEFT JOIN denumiri_pozitii dp "
                         "  ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep")
            trace.add('BASE', base_list,
                      'LIST: useri + departament + tipuri + LEFT JOIN denumiri_pozitii')
            select = ("SELECT u.id, CONCAT(u.nume,' ',u.prenume) AS nume_complet, "
                      "d.nume_dep AS departament, "
                      "COALESCE(dp.denumire_completa, t.denumire) AS functie, "
                      "t.ierarhie, u.email, u.data_ang AS data_angajare")
            trace.add('SELECT', select,
                      'COALESCE(denumiri_pozitii, tipuri) → denumire completă sau generică')
            limit = ents.top_n if ents.top_n else 100
            order = f"ORDER BY d.nume_dep, u.nume LIMIT {limit}"
            trace.add('ORDER', order,
                      f'{"top_n=" + str(ents.top_n) if ents.top_n else "dept+nume"}')
            return f"{select}\n{base_list}\n{where_str}\n{order}"

    # ────────────────────────────────────────────────────────── CONCEDII ──────

    def _build_leave(self, intent, ents, extra, user_id, trace):
        # FIX: adăugat LEFT JOIN locatii_concedii — adresa reală a destinației
        # concedii.locatie e câmp text (nestructurat), locatii_concedii e structurat (geoloc)
        base = ("FROM concedii c "
                "JOIN useri u ON c.id_ang = u.id "
                "LEFT JOIN departament d ON u.id_dep = d.id_dep "
                "LEFT JOIN tipcon tc ON c.tip = tc.tip "
                "LEFT JOIN statusuri s ON c.status = s.status "
                "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu")  # FIX
        trace.add('BASE', base,
                  'concedii + useri + departament + tipcon + statusuri + locatii_concedii')

        wheres = ["u.username != 'test'"]
        trace.add('WHERE', "u.username != 'test'", 'excludem userul de sistem')

        if ents.is_personal and user_id:
            clause = f"c.id_ang = {user_id}"
            wheres.append(clause)
            trace.add('WHERE', clause,
                      f'query personal (eu/meu) → filtram pe user_id={user_id}')
        elif extra.get('personal') and user_id:
            clause = f"c.id_ang = {user_id}"
            wheres.append(clause)
            trace.add('WHERE', clause, 'exemplul matched indică query personal')

        if ents.department:
            clause = f"UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
            wheres.append(clause)
            trace.add('WHERE', clause, f"departament detectat: '{ents.department}'")
        else:
            trace.add('NOTE', '', 'niciun departament → concedii din toată firma')

        if ents.temporal_sql:
            # Userul a specificat explicit o perioadă → o folosim ca atare
            wheres.append(ents.temporal_sql)
            trace.add('WHERE', ents.temporal_sql,
                      f"expresie temporală explicită: '{ents.temporal_label}'")
        else:
            # Niciun interval explicit → aplicăm un filtru temporal implicit de relevanță
            #
            # FĂRĂ status filter (ex: "cine e în concediu?", "concediile din HR"):
            #   → vrem concedii ACTIVE sau RECENTE (±30 zile față de azi)
            #   → filtrăm pe c.end_c >= CURDATE() - INTERVAL 30 DAY
            #
            # CU status filter (ex: "concedii aprobate", "concedii în așteptare"):
            #   → userul vrea să vadă cererile cu acel status, dar tot nu vrea
            #     să vadă cereri din 2022-2023 care nu mai sunt relevante
            #   → filtrăm pe YEAR(c.start_c) = YEAR(CURDATE()) — doar anul curent
            #   → mai larg decât ±30 zile, dar elimină istoricul vechi
            #
            has_status_filter = (ents.leave_status is not None or 'status' in extra)
            if has_status_filter:
                default_temporal = "YEAR(c.start_c) = YEAR(CURDATE())"
                wheres.append(default_temporal)
                trace.add('WHERE', default_temporal,
                          'filtru temporal implicit (status prezent): '
                          'doar concedii din ANUL CURENT — elimină istoricul vechi')
            else:
                default_temporal = "c.end_c >= CURDATE() - INTERVAL 30 DAY"
                wheres.append(default_temporal)
                trace.add('WHERE', default_temporal,
                          'filtru temporal implicit: concedii active/viitoare/'
                          'recent încheiate (±30 zile) — fără interval explicit în query')

        status_val = ents.leave_status
        status_reason = f"status detectat din query: '{ents.leave_status_label}'"
        if status_val is None and 'status' in extra:
            status_val = extra['status']
            status_reason = f"status din exemplul matched: {extra['status']}"

        if status_val is not None:
            clause = f"c.status = {status_val}"
            wheres.append(clause)
            trace.add('WHERE', clause, status_reason)
        else:
            trace.add('NOTE', '', 'niciun filtru de status → toate statusurile')

        where_str = "WHERE " + " AND ".join(wheres)

        # ── Filtru tip concediu (medical, odihnă etc.) ────────────────────────
        # "câte zile de concediu MEDICAL" → filtrăm pe tipcon.motiv LIKE '%medical%'
        if ents.leave_type:
            type_clause = f"AND UPPER(tc.motiv) LIKE UPPER('%{ents.leave_type}%')"
            where_str += f" {type_clause}"
            trace.add('WHERE', type_clause,
                      f"tip concediu detectat: '{ents.leave_type}'")

        # ── Grupare per persoană ──────────────────────────────────────────────
        # "câte zile de persoană / per angajat" → SUM(durata) GROUP BY angajat
        # Complet diferit față de COUNT(*) sau lista de concedii
        if ents.group_by_person:
            trace.add('NOTE', '',
                      'group_by_person=True → SUM(c.durata) GROUP BY angajat '
                      '(în loc de COUNT sau lista)')
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, "
                      "COUNT(c.id) AS nr_concedii, "
                      "SUM(c.durata) AS total_zile, "
                      "ROUND(AVG(c.durata), 1) AS medie_zile_per_concediu")
            trace.add('SELECT', select,
                      'SUM(durata) + COUNT + AVG per angajat — statistici individuale')
            order = ("GROUP BY u.id, u.nume, u.prenume, d.nume_dep "
                     "ORDER BY total_zile DESC LIMIT 50")
            trace.add('ORDER', order, 'ordonat după total zile DESC')
            return f"{select}\n{base}\n{where_str}\n{order}"

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_concedii"
            trace.add('SELECT', select, 'intent=count → numărăm concediile')
            return f"{select}\n{base}\n{where_str}"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, tc.motiv AS tip_concediu, "
                      "c.start_c, c.end_c, c.durata AS zile, "
                      "s.nume_status AS status, "
                      "COALESCE("
                      "  CONCAT('Str.', lc.strada, ', ', lc.oras, ', jud.', lc.judet), "
                      "  c.locatie"
                      ") AS locatie_destinatie")
            trace.add('SELECT', select,
                      'COALESCE(locatii_concedii structurat, concedii.locatie text) '
                      '→ adresa reală dacă a fost geo-localizată')
            order = "ORDER BY c.start_c DESC LIMIT 100"
            trace.add('ORDER', order, 'cele mai recente concedii primele')
            return f"{select}\n{base}\n{where_str}\n{order}"

    # ─────────────────────────────────────────────────── SOLD CONCEDII ────────

    def _build_leave_balance(self, intent, ents, extra, user_id, trace):
        # FIX: schema reală are coloane dedicate:
        #   zilecons   = zile CONSUMATE (câte ai luat)
        #   zileramase = zile RĂMASE (stocat direct, actualizat prin trigger)
        #   conluate   = număr perioade de concediu luate (din 3 maxim/an)
        #   conramase  = perioade de concediu rămase
        trace.add('NOTE', '',
                  'sold concedii: zileramase (câmpul direct) + conramase (perioade rămase)')

        select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                  "u.zilecons AS zile_consumate, "
                  "u.zileramase AS zile_ramase, "        # ← coloana directă
                  "u.conluate AS perioade_luate, "
                  "u.conramase AS perioade_ramase")      # ← max 3/an

        if user_id:
            base = f"FROM useri u WHERE u.id = {user_id}"
            trace.add('BASE', base,
                      f'interogare directă pe userul curent (user_id={user_id})')
            trace.add('SELECT', select,
                      'zileramase și conramase din useri — actualizate automat prin triggere DB')
            return f"{select}\n{base}"
        else:
            trace.add('NOTE', '', 'user_id nedisponibil → sold pentru toți angajații activi')
            base = ("FROM useri u "
                    "WHERE u.username != 'test' "
                    "ORDER BY u.zileramase ASC LIMIT 50")  # cei cu mai puțin zile primii
            trace.add('BASE', base, 'angajați activi (activ=1), ordonați după zile rămase')
            trace.add('SELECT', select, 'câmpuri sold direct din useri')
            return f"{select}\n{base}"

    # ──────────────────────────────────────────────────── DEPARTAMENTE ────────

    def _build_department(self, intent, ents, extra, user_id, trace):

        # ── Ramura LOCAȚII — prioritate maximă ───────────────────────────────
        # "locatiile departamentelor", "adresele sediilor", "unde se află dept-ul X"
        # → JOIN cu locatii_departamente, ignorăm contorizarea angajaților
        if ents.dept_location or extra.get('location'):
            trace.add('NOTE', '',
                      'dept_location=True → JOIN locatii_departamente '
                      '(adrese/sedii, nu contorizare angajați)')
            base = ("FROM departament d "
                    "LEFT JOIN locatii_departamente ld ON d.id_dep = ld.id_dep")
            trace.add('BASE', base,
                      'departament + locatii_departamente (strada, oras, judet, tara, GPS)')
            select = ("SELECT d.id_dep, d.nume_dep AS departament, "
                      "ld.strada, ld.oras, ld.judet, ld.tara, "
                      "ld.cod AS cod_postal, ld.latitudine, ld.longitudine")
            trace.add('SELECT', select, 'toate câmpurile de locație + coordonate GPS')
            order = "ORDER BY d.nume_dep"
            trace.add('ORDER', order, 'alfabetic după departament')
            return f"{select}\n{base}\n{order}"

        # ── dept_agg din superlative — prioritate față de TF-IDF extra ───────
        # Motivul: TF-IDF poate nimeri exemplul greșit (min vs max)
        # dar ents.dept_agg e detectat direct din "mulți/puțini/mare/mic" din query
        agg = ents.dept_agg or extra.get('agg', 'distribution')
        if ents.dept_agg:
            trace.add('NOTE', '',
                      f"dept_agg din superlativ: '{ents.dept_agg}' "
                      f"(override față de TF-IDF extra)")

        base = ("FROM departament d "
                "LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.username != 'test'")
        trace.add('BASE', base, 'departamente + număr angajați per departament')

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_departamente"
            trace.add('SELECT', select, 'intent=count → numărăm departamentele')
            return f"{select} FROM departament"

        elif intent == 'aggregate':
            trace.add('NOTE', '', f"agregare solicitată: '{agg}'")
            select = ("SELECT d.id_dep, d.nume_dep AS departament, "
                      "COUNT(u.id) AS nr_angajati")
            trace.add('SELECT', select, 'GROUP BY departament cu COUNT angajați')

            group = "GROUP BY d.id_dep, d.nume_dep"

            if agg == 'max_employees':
                order = "ORDER BY nr_angajati DESC LIMIT 1"
                trace.add('ORDER', order, "agg=max_employees → cel mai mare număr")
            elif agg == 'min_employees':
                having = "HAVING nr_angajati > 0"
                order = "ORDER BY nr_angajati ASC LIMIT 1"
                trace.add('ORDER', order + ' + HAVING nr_angajati > 0',
                          "agg=min_employees → cel mai mic număr (cu angajați)")
                return f"{select}\n{base}\n{group}\n{having}\n{order}"
            else:
                order = "ORDER BY nr_angajati DESC"
                trace.add('ORDER', order, 'distribuție completă, descrescător')

            return f"{select}\n{base}\n{group}\n{order}"

        else:  # list
            select = ("SELECT d.id_dep, d.nume_dep AS departament, "
                      "COUNT(u.id) AS nr_angajati")
            trace.add('SELECT', select, 'intent=list → lista departamentelor cu nr angajați')
            order = "GROUP BY d.id_dep, d.nume_dep ORDER BY nr_angajati DESC"
            trace.add('ORDER', order, 'ordonăm după număr angajați')
            return f"{select}\n{base}\n{order}"

    # ─────────────────────────────────────────────────────────── SALARII ──────

    def _build_salary(self, intent, ents, extra, user_id, trace):
        # agg poate veni din: extra (TF-IDF), sau salary_agg (detectat din query)
        agg = extra.get('agg') or ents.salary_agg

        if agg is None and intent == 'aggregate':
            agg = 'avg_company'
            trace.add('NOTE', '', "agg nedeterminat → default avg_company")

        # ── Dacă există filtru de departament + avg_company → upgrade la avg_dept ──
        # Ex: "salariu mediu HR", "salariul mediu din IT"
        # salary_agg detectează 'mediu' → avg_company, dar ents.department='HR' e setat
        # → trebuie să filtrăm media pe departamentul respectiv, nu pe toată firma
        if agg == 'avg_company' and ents.department:
            agg = 'avg_dept'
            trace.add('NOTE', '',
                      f"avg_company + dept='{ents.department}' → avg_dept cu filtru dept")

        trace.add('NOTE', '', f"query salariu, agregare: '{agg or 'personal'}'")

        if intent == 'detail' and user_id:
            base = f"FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE u.id = {user_id}"
            trace.add('BASE', base, f'salariul userului curent (user_id={user_id})')
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "t.denumire AS functie, t.salariu AS salariu_brut")
            trace.add('SELECT', select, 'câmpuri: nume, funcție, salariu brut')
            return f"{select}\n{base}"

        elif agg == 'avg_dept':
            select = ("SELECT d.nume_dep AS departament, "
                      "ROUND(AVG(t.salariu)) AS salariu_mediu, "
                      "MIN(t.salariu) AS minim, MAX(t.salariu) AS maxim")
            # Dacă avem un departament specific, filtrăm; altfel toate departamentele
            dept_filter = ""
            if ents.department:
                dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%') "
                trace.add('WHERE', dept_filter.strip(),
                          f"filtru departament: '{ents.department}'")
            base = ("FROM useri u "
                    "JOIN tipuri t ON u.tip = t.tip "
                    "JOIN departament d ON u.id_dep = d.id_dep "
                    f"WHERE u.username != 'test' {dept_filter}"
                    "GROUP BY d.id_dep, d.nume_dep ORDER BY salariu_mediu DESC")
            trace.add('SELECT', select, 'AVG/MIN/MAX salariu grupat pe departamente')
            trace.add('BASE', base, 'join useri+tipuri+departament cu GROUP BY')
            return f"{select}\n{base}"

        elif agg == 'max':
            limit = ents.top_n if ents.top_n else 5
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "t.salariu AS salariu")
            dept_filter = ""
            if ents.department:
                dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%') "
                trace.add('WHERE', dept_filter.strip(), f"filtru dept: '{ents.department}'")
            base = ("FROM useri u JOIN tipuri t ON u.tip=t.tip "
                    "JOIN departament d ON u.id_dep=d.id_dep "
                    f"WHERE u.username!='test' {dept_filter}"
                    "ORDER BY t.salariu DESC "
                    f"LIMIT {limit}")
            trace.add('SELECT', select, f'top {limit} angajați după salariu descrescător')
            trace.add('BASE', base, f'ORDER BY salariu DESC LIMIT {limit}')
            return f"{select}\n{base}"

        elif agg == 'min':
            limit = ents.top_n if ents.top_n else 5
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "t.salariu AS salariu")
            dept_filter = ""
            if ents.department:
                dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%') "
                trace.add('WHERE', dept_filter.strip(), f"filtru dept: '{ents.department}'")
            base = ("FROM useri u JOIN tipuri t ON u.tip=t.tip "
                    "JOIN departament d ON u.id_dep=d.id_dep "
                    f"WHERE u.username!='test' {dept_filter}"
                    "AND t.salariu > 0 "
                    "ORDER BY t.salariu ASC "
                    f"LIMIT {limit}")
            trace.add('SELECT', select, f'top {limit} angajați cu salariu minim')
            trace.add('BASE', base, f'ORDER BY salariu ASC LIMIT {limit}')
            return f"{select}\n{base}"

        else:  # avg_company
            select = ("SELECT ROUND(AVG(t.salariu)) AS salariu_mediu_firma, "
                      "MIN(t.salariu) AS salariu_minim, MAX(t.salariu) AS salariu_maxim")
            base = ("FROM useri u JOIN tipuri t ON u.tip=t.tip "
                    "WHERE u.username != 'test'")
            trace.add('SELECT', select, 'statistici salariale la nivel de firmă')
            trace.add('BASE', base, 'join useri+tipuri, fără groupare')
            return f"{select}\n{base}"

    # ─────────────────────────────────────────────────────────── PROIECTE ─────

    def _build_project(self, intent, ents, extra, user_id, trace):
        base = ("FROM proiecte p "
                "LEFT JOIN useri u ON p.supervizor = u.id "
                "LEFT JOIN tasks t ON p.id = t.id_prj")
        trace.add('BASE', base, 'proiecte + supervizor + număr taskuri')

        wheres = []
        project_status = extra.get('status')

        if project_status == 'active':
            clause = "p.start <= CURDATE() AND p.end >= CURDATE()"
            wheres.append(clause)
            trace.add('WHERE', clause, "status='active' → proiecte în curs")
        elif project_status == 'inactive':
            clause = "p.end < CURDATE()"
            wheres.append(clause)
            trace.add('WHERE', clause, "status='inactive' → proiecte terminate")
        else:
            trace.add('NOTE', '', 'niciun filtru de status → toate proiectele')

        where_str = ("WHERE " + " AND ".join(wheres)) if wheres else ""

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_proiecte"
            trace.add('SELECT', select, 'intent=count → numărăm proiectele')
            return f"{select}\n{base}\n{where_str}".strip()

        else:
            select = ("SELECT p.id, p.nume AS proiect, p.start, p.end AS deadline, "
                      "CONCAT(u.nume,' ',u.prenume) AS supervizor, "
                      "COUNT(t.id) AS nr_taskuri")
            trace.add('SELECT', select, 'intent=list → detalii per proiect')
            group = ("GROUP BY p.id, p.nume, p.start, p.end, u.nume, u.prenume "
                     "ORDER BY p.end ASC LIMIT 50")
            trace.add('ORDER', group, 'deadline-urile cele mai apropiate primele')
            return f"{select}\n{base}\n{where_str}\n{group}".strip()

    # ──────────────────────────────────────────────────────────── TASKURI ─────

    def _build_task(self, intent, ents, extra, user_id, trace):
        # FIX: tasks.status este FK → statusuri2(id, procent)
        # statusuri2.procent e procentul de completare: 0%, 25%, 75%, 100%
        base = ("FROM tasks t "
                "LEFT JOIN useri u ON t.id_ang = u.id "
                "LEFT JOIN proiecte p ON t.id_prj = p.id "
                "LEFT JOIN statusuri2 s2 ON t.status = s2.id")  # ← JOIN real
        trace.add('BASE', base,
                  'taskuri + angajat + proiect + statusuri2 (procent completare)')

        wheres = []

        if (ents.is_personal or extra.get('personal')) and user_id:
            clause = f"t.id_ang = {user_id}"
            wheres.append(clause)
            trace.add('WHERE', clause,
                      f'query personal → taskurile lui user_id={user_id}')

        # Filtrare după procent de completare din statusuri2
        task_status_map = {
            'todo':        ("s2.procent = 0",              "neînceput (0%)"),
            'in_progress': ("s2.procent > 0 AND s2.procent < 100", "în progres (1-99%)"),
            'done':        ("s2.procent = 100",            "completat (100%)"),
        }
        status_key = extra.get('status')
        if status_key in task_status_map:
            clause, label = task_status_map[status_key]
            wheres.append(clause)
            trace.add('WHERE', clause,
                      f"status='{label}' via statusuri2.procent (nu 0/1/2!)")
        else:
            trace.add('NOTE', '', 'niciun filtru status → toate taskurile')

        if ents.temporal_sql:
            adapted = ents.temporal_sql.replace('c.start_c', 't.end')
            wheres.append(adapted)
            trace.add('WHERE', adapted,
                      f"temporal '{ents.temporal_label}' adaptat pentru t.end")

        where_str = ("WHERE " + " AND ".join(wheres)) if wheres else ""

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_taskuri"
            trace.add('SELECT', select, 'intent=count → numărăm taskurile')
            return f"{select}\n{base}\n{where_str}".strip()
        else:
            select = ("SELECT t.id, t.nume AS task, "
                      "CONCAT(u.nume,' ',u.prenume) AS responsabil, "
                      "p.nume AS proiect, t.start, t.end AS deadline, "
                      "s2.procent AS procent_completare, "
                      "CASE "
                      "WHEN s2.procent = 100 THEN 'Completat' "
                      "WHEN s2.procent = 0 THEN 'Neînceput' "
                      "ELSE CONCAT(s2.procent, '% - În progres') "
                      "END AS status_text")
            trace.add('SELECT', select,
                      'intent=list → procent real din statusuri2, nu CASE hardcodat')
            order = "ORDER BY t.end ASC LIMIT 100"
            trace.add('ORDER', order, 'deadline-urile cele mai apropiate primele')
            return f"{select}\n{base}\n{where_str}\n{order}".strip()

    # ──────────────────────────────────────────────────────── ADEVERINTE ──────

    def _build_certificate(self, intent, ents, extra, user_id, trace):
        base = ("FROM adeverinte a "
                "JOIN useri u ON a.id_ang = u.id "
                "LEFT JOIN tip_adev ta ON a.tip = ta.id "
                "LEFT JOIN statusuri s ON a.status = s.status")
        trace.add('BASE', base, 'adeverinte + angajat + tip adeverinta + status')

        wheres = ["u.username != 'test'"]
        trace.add('WHERE', "u.username != 'test'", 'excludem userul de sistem')

        if (ents.is_personal or extra.get('personal')) and user_id:
            clause = f"a.id_ang = {user_id}"
            wheres.append(clause)
            trace.add('WHERE', clause, f'query personal → adeverintele lui user_id={user_id}')

        # Status din query sau din exemplul matched
        status_val = ents.cert_status
        status_reason = f"status detectat din query: '{ents.cert_status_label}'"
        if status_val is None and 'status' in extra:
            status_val = extra['status']
            status_reason = f"status din exemplul matched: {extra['status']}"

        # ── Filtru temporal implicit pentru adeverințe ───────────────────────
        # adeverinte.creare = data la care s-a creat cererea
        #
        # Fără status filter → ultimele 6 luni (cereri recente relevante)
        # Cu status filter   → anul curent (elimină istoricul vechi din 2022-2023,
        #                       dar arată toate cererile pending/aprobate din an)
        # Personal (eu/mele) → fără limită temporală (userul vrea TOATE ale lui)
        has_status_filter = (ents.cert_status is not None or 'status' in extra)
        if ents.is_personal:
            trace.add('NOTE', '',
                      'query personal → fără limită temporală (toate adeverințele userului)')
        elif has_status_filter:
            default_temporal = "YEAR(a.creare) = YEAR(CURDATE())"
            wheres.append(default_temporal)
            trace.add('WHERE', default_temporal,
                      'filtru temporal implicit (status prezent): '
                      'doar adeverințe din ANUL CURENT — elimină istoricul vechi')
        else:
            default_temporal = "a.creare >= CURDATE() - INTERVAL 6 MONTH"
            wheres.append(default_temporal)
            trace.add('WHERE', default_temporal,
                      'filtru temporal implicit: adeverințe din ultimele 6 luni')

        where_str = "WHERE " + " AND ".join(wheres)

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_adeverinte"
            trace.add('SELECT', select, 'intent=count → numărăm adeverintele')
            return f"{select}\n{base}\n{where_str}"

        else:
            select = ("SELECT a.id, CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "ta.denumire AS tip_adeverinta, a.motiv, "
                      "s.nume_status AS status, a.creare AS data_cerere")
            trace.add('SELECT', select, 'intent=list → detalii per adeverinta')
            order = "ORDER BY a.creare DESC LIMIT 100"
            trace.add('ORDER', order, 'cele mai recente cereri primele')
            return f"{select}\n{base}\n{where_str}\n{order}"

    # ─────────────────────────────────────────────────────────── POSTURI ──────

    def _build_position(self, intent, ents, extra, user_id, trace):

        if ents.department:
            # ── Filtrare după departament ─────────────────────────────────────
            # PROBLEMA cu abordarea veche:
            #   tipuri.departament_specific e NULL pentru majoritatea pozițiilor
            #   → JOIN pe acel câmp returnează 0 rânduri
            #
            # SOLUȚIE: mergem prin useri — găsim ce tip-uri (poziții) au
            # angajații din departamentul cerut, indiferent de departament_specific
            #
            #   tipuri t
            # Cautăm tipurile de posturi asociate departamentului.
            # NU filtrăm pe u.activ — vrem tipurile care EXISTĂ în dept,
            # nu doar cele ocupate de angajați activi în momentul de față.
            # (Ex: dacă singurul angajat HR a plecat, tot există tipul "Specialist HR")
            # Folosim JOIN INNER pe useri pentru a lega tipul de departament,
            # dar fără condiția activ.

            base = ("FROM tipuri t "
                    "JOIN useri u ON u.tip = t.tip "
                    "JOIN departament d ON u.id_dep = d.id_dep "
                    "LEFT JOIN denumiri_pozitii dp "
                    "  ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep")
            trace.add('BASE', base,
                      'tipuri → useri → departament (fără filtru activ — vrem tipurile, nu persoanele)')

            clause = f"UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
            trace.add('WHERE', clause,
                      f"posturi din departamentul '{ents.department}' (toți angajații, activi sau nu)")

            select = ("SELECT DISTINCT "
                      "t.denumire AS denumire_generica, "
                      "COALESCE(dp.denumire_completa, t.denumire) AS denumire_completa, "
                      "t.salariu, t.ierarhie, "
                      "d.nume_dep AS departament")
            trace.add('SELECT', select, 'poziții distincte din acel departament cu salarii')
            order = "ORDER BY t.ierarhie DESC, t.denumire"
            trace.add('ORDER', order, 'ierarhie descrescătoare, apoi alfabetic')
            return (f"{select}\nFROM tipuri t "
                    f"JOIN useri u ON u.tip = t.tip "
                    f"JOIN departament d ON u.id_dep = d.id_dep "
                    f"LEFT JOIN denumiri_pozitii dp "
                    f"  ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep "
                    f"WHERE {clause}\n{order}")

        else:
            # ── Fără filtru de departament — toate pozițiile din firmă ─────────
            # Folosim LEFT JOIN pe tipuri.departament_specific (poate fi NULL)
            # pentru a obține denumirea departamentului dacă există
            base = ("FROM tipuri t "
                    "LEFT JOIN departament d ON t.departament_specific = d.id_dep "
                    "LEFT JOIN denumiri_pozitii dp "
                    "  ON t.tip = dp.tip_pozitie AND (d.id_dep = dp.id_dep OR dp.id_dep IS NULL)")
            trace.add('BASE', base,
                      'toate tipurile + departament_specific (poate fi NULL) + denumiri_pozitii')

            select = ("SELECT DISTINCT "
                      "t.denumire AS denumire_generica, "
                      "COALESCE(dp.denumire_completa, t.denumire) AS denumire_completa, "
                      "t.salariu, t.ierarhie, "
                      "d.nume_dep AS departament_specific")
            trace.add('SELECT', select,
                      'toate pozițiile din firmă cu denumiri complete și salarii')
            order = "ORDER BY t.ierarhie DESC, t.denumire"
            trace.add('ORDER', order, 'ierarhie descrescătoare, apoi alfabetic')
            return f"{select}\n{base}\n{order}"

    def _build_job_opening(self, intent, ents, extra, user_id, trace):
        base = ("FROM joburi j "
                "LEFT JOIN departament d ON j.departament = d.id_dep "
                )
        # trace.add('BASE', base, 'posturi active (joburi.activ=1)')
        select = ("SELECT j.id, j.titlu AS post, j.req AS cerinte, "
                  "d.nume_dep AS departament, j.start, j.end AS termen_limita")
        trace.add('SELECT', select, 'detalii posturi deschise')
        order = "ORDER BY j.start DESC LIMIT 50"
        trace.add('ORDER', order, 'cele mai recente posturi primele')
        return f"{select}\n{base}\n{order}"

    # ─────────────────────────────────────────────────────────── VECHIME ──────
    # Entitate nouă — detectată de QuestionWordAnalyzer când userul întreabă
    # "care este vechimea", "de când lucrează", "câți ani are la firmă" etc.

    def _build_tenure(self, intent, ents, extra, user_id, trace):
        trace.add('NOTE', '',
                  'query despre vechime/senioritate → calculăm din data_ang')

        if ents.is_personal and user_id:
            base = f"FROM useri u WHERE u.id = {user_id}"
            trace.add('BASE', base,
                      f'vechimea userului curent (user_id={user_id})')
        else:
            base = "FROM useri u WHERE u.username != 'test'"
            trace.add('BASE', base, 'vechimea tuturor angajaților')
            if ents.department:
                base += (f" AND u.id_dep = (SELECT id_dep FROM departament "
                         f"WHERE UPPER(nume_dep) LIKE UPPER('%{ents.department}%') LIMIT 1)")
                trace.add('WHERE', f"departament='{ents.department}'",
                          'filtru departament detectat')

        select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                  "u.data_ang AS data_angajare, "
                  "FLOOR(DATEDIFF(CURDATE(), u.data_ang)/365) AS ani_vechime, "
                  "MOD(FLOOR(DATEDIFF(CURDATE(), u.data_ang)/30), 12) AS luni_extra")
        trace.add('SELECT', select,
                  'DATEDIFF pentru ani și luni de vechime calculate dinamic')

        order = "ORDER BY u.data_ang ASC"
        trace.add('ORDER', order, 'cel mai vechi angajat primul')

        return f"{select}\n{base}\n{order}"

    # ─────────────────────────────────────────────────── SĂRBĂTORI LEGALE ─────

    def _build_holiday(self, intent, ents, extra, user_id, trace):
        """
        Interogare pe tabela `sarbatori` (zile libere legale naționale).
        Schema: sarbatori(zi DATE, nume VARCHAR)
        Există și tabela `libere` cu aceeași structură — o includem prin UNION.

        Variante:
          - toate sărbătorile din an
          - sărbătorile rămase (zi >= CURDATE())
          - numărul de sărbători
          - sărbătorile dintr-o lună anume
        """
        trace.add('NOTE', '', 'query sărbători legale → tabela sarbatori (+ libere prin UNION)')

        # Filtru temporal: "rămase" sau explicit (luna aceasta etc.)
        wheres_s = ["YEAR(zi) = YEAR(CURDATE())"]   # implicit: anul curent
        wheres_l = ["YEAR(zi) = YEAR(CURDATE())"]

        if ents.holiday_remaining or extra.get('temporal') == 'remaining':
            # Doar sărbătorile care nu au trecut încă
            wheres_s = ["zi >= CURDATE()"]
            wheres_l = ["zi >= CURDATE()"]
            trace.add('WHERE', "zi >= CURDATE()",
                      "ramase detectat → doar sarbatorile viitoare din an")
        elif ents.temporal_sql:
            # Ex: MONTH(zi)=MONTH(CURDATE()) pentru "luna aceasta"
            adapted = ents.temporal_sql.replace('c.start_c', 'zi')
            wheres_s = [adapted]
            wheres_l = [adapted]
            trace.add('WHERE', adapted,
                      f"temporal explicit: '{ents.temporal_label}'")
        else:
            trace.add('WHERE', "YEAR(zi) = YEAR(CURDATE())",
                      'filtru implicit: sărbătorile din ANUL CURENT')

        where_s = "WHERE " + " AND ".join(wheres_s)
        where_l = "WHERE " + " AND ".join(wheres_l)

        if intent == 'count':
            sql = (f"SELECT COUNT(*) AS total_sarbatori "
                   f"FROM ("
                   f"  SELECT zi, nume FROM sarbatori {where_s} "
                   f"  UNION SELECT zi, nume FROM libere {where_l}"
                   f") AS toate_liberele")
            trace.add('SELECT', sql[:80], 'COUNT sărbători + zile libere (UNION)')
            return sql

        select = "SELECT zi AS data, nume AS sarbatoare"
        base   = (f"FROM ("
                  f"  SELECT zi, nume FROM sarbatori {where_s} "
                  f"  UNION SELECT zi, nume FROM libere {where_l}"
                  f") AS toate_liberele")
        order  = "ORDER BY zi ASC"

        trace.add('SELECT', select, 'data + numele sărbătorii')
        trace.add('BASE',   base,   'sarbatori UNION libere — ambele tabele')
        trace.add('ORDER',  order,  'ordonate cronologic')
        return f"{select}\n{base}\n{order}"

    # ──────────────────────────────────────── ELIGIBILITATE CONCEDIU ──────────

    def _build_leave_eligibility(self, intent, ents, extra, user_id, trace):
        """
        "Am voie să-mi iau concediu în perioada X?"
        Returnează 3 secțiuni combinate cu UNION ALL:
          1. sold  — zile rămase ale angajatului
          2. conflict — alte concedii aprobate care se suprapun cu perioada cerută
          3. restrictie — restricții active în acea perioadă (tabela restrictii)
        """
        trace.add('NOTE', '', 'eligibilitate → sold + conflicte + restricții (UNION ALL)')

        uid = user_id or 0

        if ents.date_start and ents.date_end:
            start = f"'{ents.date_start}'"
            end   = f"'{ents.date_end}'"
            trace.add('NOTE', '', f"interval: {ents.date_start} → {ents.date_end}")
        else:
            start = "DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01')"
            end   = "LAST_DAY(CURDATE() + INTERVAL 1 MONTH)"
            trace.add('NOTE', '', 'interval nedetectat → luna viitoare ca fallback')

        q1 = (f"SELECT 'sold' AS sectiune, "
              f"CONCAT(u.nume,' ',u.prenume) AS info, "
              f"CAST(u.zileramase AS CHAR) AS valoare, "
              f"'zile disponibile' AS detaliu "
              f"FROM useri u WHERE u.id = {uid}")

        q2 = (f"SELECT 'conflict' AS sectiune, "
              f"CONCAT(u.nume,' ',u.prenume) AS info, "
              f"DATE_FORMAT(c.start_c,'%d/%m/%Y') AS valoare, "
              f"CONCAT('concediu aprobat: ',DATE_FORMAT(c.start_c,'%d/%m'),"
              f"' - ',DATE_FORMAT(c.end_c,'%d/%m')) AS detaliu "
              f"FROM concedii c JOIN useri u ON c.id_ang = u.id "
              f"WHERE c.id_ang = {uid} AND c.status IN (1,2) "
              f"AND c.start_c <= {end} AND c.end_c >= {start}")

        q3 = (f"SELECT 'restrictie' AS sectiune, "
              f"r.motiv AS info, "
              f"DATE_FORMAT(r.start_r,'%d/%m/%Y') AS valoare, "
              f"CONCAT('restrictie: ',DATE_FORMAT(r.start_r,'%d/%m'),"
              f"' - ',DATE_FORMAT(r.end_r,'%d/%m')) AS detaliu "
              f"FROM restrictii r "
              f"WHERE r.start_r <= {end} AND r.end_r >= {start}")

        trace.add('SELECT', q1[:70], 'sect.1: sold zile angajat')
        trace.add('SELECT', q2[:70], 'sect.2: conflicte concedii aprobate')
        trace.add('SELECT', q3[:70], 'sect.3: restricții active în perioadă')
        return f"{q1}\nUNION ALL\n{q2}\nUNION ALL\n{q3}\nORDER BY sectiune"

    # ──────────────────────────────────────────────────── ECHIPA MEA ──────────

    def _build_team_leave(self, intent, ents, extra, user_id, trace):
        """Concediile colegilor din echipa mea (via membrii_echipe)."""
        uid = user_id or 0
        trace.add('NOTE', '', f'concedii echipă user_id={uid} via membrii_echipe')
        base = (f"FROM concedii c "
                f"JOIN useri u ON c.id_ang = u.id "
                f"JOIN membrii_echipe me ON me.id_ang = u.id "
                f"JOIN membrii_echipe me2 ON me2.id_echipa = me.id_echipa "
                f"  AND me2.id_ang = {uid} "
                f"LEFT JOIN departament d ON u.id_dep = d.id_dep "
                f"LEFT JOIN tipcon tc ON c.tip = tc.tip "
                f"LEFT JOIN statusuri s ON c.status = s.status")
        wheres = [f"u.id != {uid}"]  # excludem userul curent
        if ents.temporal_sql:
            wheres.append(ents.temporal_sql)
            trace.add('WHERE', ents.temporal_sql, f"temporal: '{ents.temporal_label}'")
        else:
            wheres.append("c.end_c >= CURDATE() - INTERVAL 14 DAY")
            trace.add('WHERE', "c.end_c >= CURDATE() - INTERVAL 14 DAY",
                      'implicit: ±14 zile față de azi')
        where_str = "WHERE " + " AND ".join(wheres)
        select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS coleg, "
                  "tc.motiv AS tip_concediu, c.start_c, c.end_c, "
                  "c.durata AS zile, s.nume_status AS status")
        trace.add('SELECT', select, 'concediile colegilor din aceeași echipă')
        return f"{select}\n{base}\n{where_str}\nORDER BY c.start_c ASC LIMIT 50"

    def _build_team_salary(self, intent, ents, extra, user_id, trace):
        """Salariile colegilor din echipa mea."""
        uid = user_id or 0
        trace.add('NOTE', '', f'salarii echipă user_id={uid}')
        base = (f"FROM useri u "
                f"JOIN tipuri t ON u.tip = t.tip "
                f"JOIN membrii_echipe me ON me.id_ang = u.id "
                f"JOIN membrii_echipe me2 ON me2.id_echipa = me.id_echipa "
                f"  AND me2.id_ang = {uid} "
                f"LEFT JOIN departament d ON u.id_dep = d.id_dep")
        where = f"WHERE IFNULL(u.activ, 1) != 0 AND u.id != {uid}"
        agg = extra.get('agg') or ents.salary_agg
        if agg == 'max':
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS coleg, "
                      "t.denumire AS functie, t.salariu AS salariu")
            trace.add('SELECT', select, 'cel mai mare salariu din echipă')
            return f"{select}\n{base}\n{where}\nORDER BY t.salariu DESC LIMIT 1"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS coleg, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "t.salariu AS salariu")
            trace.add('SELECT', select, 'toți colegii cu salarii')
            return f"{select}\n{base}\n{where}\nORDER BY t.salariu DESC"

    def _build_team_members(self, intent, ents, extra, user_id, trace):
        """Membrii echipei mele / cine lucrează la proiectul X."""
        uid = user_id or 0
        if ents.project_name:
            trace.add('NOTE', '', f"membrii proiect '{ents.project_name}'")
            base = (f"FROM membrii_echipe me "
                    f"JOIN useri u ON me.id_ang = u.id "
                    f"JOIN echipe e ON me.id_echipa = e.id "
                    f"JOIN proiecte p ON e.id_prj = p.id "
                    f"LEFT JOIN tipuri t ON u.tip = t.tip "
                    f"LEFT JOIN departament d ON u.id_dep = d.id_dep")
            where = f"WHERE UPPER(p.nume) LIKE UPPER('%{ents.project_name}%') AND IFNULL(u.activ, 1) != 0"
        else:
            trace.add('NOTE', '', f'membrii echipei mele user_id={uid}')
            base = (f"FROM membrii_echipe me "
                    f"JOIN useri u ON me.id_ang = u.id "
                    f"JOIN membrii_echipe me2 ON me2.id_echipa = me.id_echipa "
                    f"  AND me2.id_ang = {uid} "
                    f"LEFT JOIN tipuri t ON u.tip = t.tip "
                    f"LEFT JOIN departament d ON u.id_dep = d.id_dep")
            where = f"WHERE IFNULL(u.activ, 1) != 0 AND u.id != {uid}"
        select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                  "d.nume_dep AS departament, t.denumire AS functie, "
                  "u.email, u.telefon")
        trace.add('SELECT', select, 'membrii echipei cu contact')
        return f"{select}\n{base}\n{where}\nORDER BY u.nume LIMIT 50"

    # ──────────────────────────────────────────────────── TASK STATS ──────────

    def _build_task_stats(self, intent, ents, extra, user_id, trace):
        """Statistici taskuri: media lunară, performers, workload departament."""
        agg = extra.get('agg', 'avg_monthly')
        trace.add('NOTE', '', f'task stats, agg={agg}')

        if agg == 'avg_monthly':
            # Câte taskuri completate în medie pe lună
            select = ("SELECT MONTH(t.end) AS luna, YEAR(t.end) AS an, "
                      "COUNT(*) AS taskuri_completate")
            base = ("FROM tasks t "
                    "JOIN statusuri2 s2 ON t.status = s2.id "
                    "WHERE s2.procent = 100 "
                    "AND t.end >= CURDATE() - INTERVAL 12 MONTH "
                    "GROUP BY YEAR(t.end), MONTH(t.end) "
                    "ORDER BY an DESC, luna DESC")
            trace.add('SELECT', select, 'taskuri completate grupate lunar (12 luni)')
            trace.add('BASE', base, 'statusuri2.procent=100 → completat')
            return f"{select}\n{base}"

        elif agg == 'low_performers':
            # Angajați cu < 2 taskuri realizate într-o lună + salariul lor mediu
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, "
                      "COUNT(t.id) AS taskuri_completate_luna, "
                      "t2_sal.salariu AS salariu_brut")
            base = (f"FROM useri u "
                    f"LEFT JOIN tasks t ON t.id_ang = u.id "
                    f"  AND MONTH(t.end) = MONTH(CURDATE()) "
                    f"  AND t.status IN (SELECT id FROM statusuri2 WHERE procent = 100) "
                    f"LEFT JOIN tipuri t2_sal ON u.tip = t2_sal.tip "
                    f"LEFT JOIN departament d ON u.id_dep = d.id_dep "
                    f"WHERE IFNULL(u.activ, 1) != 0 AND u.username != 'test' "
                    f"GROUP BY u.id, u.nume, u.prenume, d.nume_dep, t2_sal.salariu "
                    f"HAVING COUNT(t.id) < 2 "
                    f"ORDER BY taskuri_completate_luna ASC, salariu_brut DESC")
            trace.add('SELECT', select, 'angajați cu < 2 taskuri completate luna aceasta')
            trace.add('BASE', base, 'LEFT JOIN tasks + HAVING COUNT < 2')
            return f"{select}\n{base}"

        else:  # workload_dept
            # Departamentul cu cel mai mare workload (suma taskuri active)
            select = ("SELECT d.nume_dep AS departament, "
                      "COUNT(t.id) AS taskuri_active, "
                      "COUNT(DISTINCT t.id_ang) AS angajati_implicati")
            base = ("FROM tasks t "
                    "JOIN useri u ON t.id_ang = u.id "
                    "JOIN departament d ON u.id_dep = d.id_dep "
                    "JOIN statusuri2 s2 ON t.status = s2.id "
                    "WHERE s2.procent < 100 AND IFNULL(u.activ, 1) != 0 "
                    "GROUP BY d.id_dep, d.nume_dep "
                    "ORDER BY taskuri_active DESC")
            trace.add('SELECT', select, 'taskuri active per departament')
            trace.add('BASE', base, 'statusuri2.procent < 100 → taskuri nefinalizate')
            return f"{select}\n{base}"

    # ──────────────────────────────────────────── CONCEDIU PERSONAL STATS ─────

    def _build_leave_personal_stats(self, intent, ents, extra, user_id, trace):
        """Câte zile de concediu medical am avut anul ăsta."""
        uid = user_id or 0
        trace.add('NOTE', '', f'statistici concediu personal user_id={uid}')
        leave_type_filter = ""
        if ents.leave_type:
            leave_type_filter = f"AND UPPER(tc.motiv) LIKE UPPER('%{ents.leave_type}%')"
        temporal = "AND YEAR(c.start_c) = YEAR(CURDATE())"
        if ents.temporal_sql:
            temporal = f"AND {ents.temporal_sql}"
        select = ("SELECT tc.motiv AS tip_concediu, "
                  "COUNT(*) AS nr_cereri, "
                  "SUM(c.durata) AS total_zile, "
                  "MIN(c.start_c) AS primul_concediu, "
                  "MAX(c.end_c) AS ultimul_concediu")
        base = (f"FROM concedii c "
                f"JOIN tipcon tc ON c.tip = tc.tip "
                f"WHERE c.id_ang = {uid} "
                f"{temporal} {leave_type_filter} "
                f"GROUP BY tc.tip, tc.motiv "
                f"ORDER BY total_zile DESC")
        trace.add('SELECT', select, 'statistici concedii per tip pentru userul curent')
        trace.add('BASE', base, f'filtru: user_id={uid} + an curent + tip concediu')
        return f"{select}\n{base}"

    def _build_next_leave(self, intent, ents, extra, user_id, trace):
        """Când este următorul meu concediu aprobat."""
        uid = user_id or 0
        trace.add('NOTE', '', f'next leave user_id={uid}')
        select = ("SELECT tc.motiv AS tip_concediu, "
                  "c.start_c AS data_inceput, c.end_c AS data_sfarsit, "
                  "c.durata AS zile, s.nume_status AS status, c.locatie")
        base = (f"FROM concedii c "
                f"JOIN tipcon tc ON c.tip = tc.tip "
                f"LEFT JOIN statusuri s ON c.status = s.status "
                f"WHERE c.id_ang = {uid} "
                f"AND c.start_c > CURDATE() "
                f"AND c.status IN (0,1,2) "
                f"ORDER BY c.start_c ASC LIMIT 3")
        trace.add('SELECT', select, 'următoarele concedii planificate (viitoare)')
        trace.add('BASE', base, 'start_c > CURDATE() + status != respins')
        return f"{select}\n{base}"

    # ──────────────────────────────────────────────── ANGAJĂRI / CONCEDIERI ───

    def _build_hiring_stats(self, intent, ents, extra, user_id, trace):
        """Câte angajări s-au făcut în ultima lună/an."""
        period = extra.get('period') or ents.hiring_period or 'last_month'
        period_map = {
            'last_month': ("data_ang >= CURDATE() - INTERVAL 1 MONTH", "ultima lună"),
            'last_year':  ("data_ang >= CURDATE() - INTERVAL 1 YEAR", "ultimul an"),
            'last_3m':    ("data_ang >= CURDATE() - INTERVAL 3 MONTH", "ultimele 3 luni"),
            'last_3y':    ("data_ang >= CURDATE() - INTERVAL 3 YEAR", "ultimii 3 ani"),
        }
        clause, label = period_map.get(period, period_map['last_month'])
        trace.add('NOTE', '', f'angajări în: {label}')

        if intent == 'count':
            select = f"SELECT COUNT(*) AS angajari_{period}"
            base = f"FROM useri WHERE {clause} AND username != 'test'"
            trace.add('SELECT', select, f'numărul de angajări din {label}')
            return f"{select}\n{base}"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "u.data_ang AS data_angajare")
            base = (f"FROM useri u "
                    f"LEFT JOIN departament d ON u.id_dep = d.id_dep "
                    f"LEFT JOIN tipuri t ON u.tip = t.tip "
                    f"WHERE {clause} AND u.username != 'test' "
                    f"ORDER BY u.data_ang DESC LIMIT 50")
            trace.add('SELECT', select, f'lista angajaților din {label}')
            return f"{select}\n{base}"

    def _build_termination_stats(self, intent, ents, extra, user_id, trace):
        """Câți angajați au fost concediați (activ=0, data_modif recentă)."""
        trace.add('NOTE', '', 'concedieri recente: activ=0 + data_modif în ultima lună')
        # Nu avem un câmp explicit de data_concediere, folosim data_modif
        if intent == 'count':
            select = "SELECT COUNT(*) AS concediati_luna_aceasta"
            base = ("FROM useri WHERE activ = 0 "
                    "AND data_modif >= CURDATE() - INTERVAL 1 MONTH "
                    "AND username != 'test'")
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "u.data_modif AS data_plecarii")
            base = ("FROM useri u "
                    "LEFT JOIN departament d ON u.id_dep = d.id_dep "
                    "LEFT JOIN tipuri t ON u.tip = t.tip "
                    "WHERE u.activ = 0 "
                    "AND u.data_modif >= CURDATE() - INTERVAL 1 MONTH "
                    "AND u.username != 'test' "
                    "ORDER BY u.data_modif DESC LIMIT 50")
        trace.add('SELECT', select, 'angajați inactivi cu data_modif recentă')
        trace.add('BASE', base, 'activ=0 + data_modif în ultima lună')
        return f"{select}\n{base}"

    # ─────────────────────────────────────────────────── SALARIU POZIȚIE ──────

    def _build_position_salary(self, intent, ents, extra, user_id, trace):
        """Salariul min/max/avg pentru poziția curentă sau o poziție anume."""
        uid = user_id or 0
        agg = (extra.get('agg') or ents.salary_agg_personal or 'avg')
        trace.add('NOTE', '', f'salariu poziție, agg={agg}')

        agg_expr = {
            'min': "MIN(t2.salariu) AS salariu_minim",
            'max': "MAX(t2.salariu) AS salariu_maxim",
            'avg': "ROUND(AVG(t2.salariu)) AS salariu_mediu, MIN(t2.salariu) AS minim, MAX(t2.salariu) AS maxim",
        }.get(agg, "ROUND(AVG(t2.salariu)) AS salariu_mediu")

        if ents.is_personal and uid:
            # Salariul pentru poziția MEA — găsim tipul userului curent
            select = (f"SELECT t.denumire AS pozitia_mea, {agg_expr}, "
                      f"COUNT(u2.id) AS nr_angajati_pe_aceasta_pozitie")
            base = (f"FROM useri u "
                    f"JOIN tipuri t ON u.tip = t.tip "
                    f"JOIN useri u2 ON u2.tip = t.tip AND IFNULL(u2.activ, 1) != 0 "
                    f"JOIN tipuri t2 ON u2.tip = t2.tip "
                    f"WHERE u.id = {uid} "
                    f"GROUP BY t.tip, t.denumire")
            trace.add('SELECT', select, f'{agg} salariu pentru pozitia userului curent')
            trace.add('BASE', base, f'user {uid} → tip → toți cu același tip → avg/min/max')
        else:
            # Salariul mediu pe o anumită poziție din query
            pos_filter = ""
            if ents.position_name:
                pos_filter = f"WHERE UPPER(t.denumire) LIKE UPPER('%{ents.position_name}%')"
            elif ents.department:
                # fallback la dept
                pos_filter = (f"WHERE UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%') "
                              f"AND IFNULL(u.activ, 1) != 0")
                select = (f"SELECT t.denumire AS pozitie, {agg_expr}")
                base = (f"FROM tipuri t "
                        f"JOIN useri u ON u.tip = t.tip "
                        f"JOIN departament d ON u.id_dep = d.id_dep "
                        f"{pos_filter} "
                        f"GROUP BY t.tip, t.denumire "
                        f"ORDER BY salariu_mediu DESC LIMIT 10")
                trace.add('SELECT', select, f'{agg} salariu per pozitie in dept')
                return f"{select}\n{base}"
            select = (f"SELECT t.denumire AS pozitie, {agg_expr}, "
                      f"COUNT(u.id) AS nr_angajati")
            base = (f"FROM tipuri t "
                    f"LEFT JOIN useri u ON u.tip = t.tip AND IFNULL(u.activ, 1) != 0 "
                    f"{pos_filter} "
                    f"GROUP BY t.tip, t.denumire "
                    f"ORDER BY t.ierarhie DESC, t.denumire LIMIT 20")
            trace.add('SELECT', select, f'{agg} salariu per pozitie (toate)')
        trace.add('BASE', base, 'din tipuri + useri activi')
        return f"{select}\n{base}"

    def _build_salary_comparison(self, intent, ents, extra, user_id, trace):
        """Angajați pe aceeași poziție ca mine, cu salariu mai mare."""
        uid = user_id or 0
        trace.add('NOTE', '',
                  f'comparație salariu: aceeași poziție ca user {uid} + salariu mai mare')
        select = ("SELECT CONCAT(u2.nume,' ',u2.prenume) AS coleg, "
                  "t.denumire AS pozitie, t.salariu AS salariu, "
                  "FLOOR(DATEDIFF(CURDATE(), u2.data_ang)/365) AS ani_vechime")
        base = (f"FROM useri u "
                f"JOIN tipuri t ON u.tip = t.tip "
                f"JOIN useri u2 ON u2.tip = t.tip "
                f"  AND u2.id != {uid} AND IFNULL(u2.activ, 1) != 0 "
                f"WHERE u.id = {uid} "
                f"AND t.salariu > (SELECT t2.salariu FROM useri u3 "
                f"                 JOIN tipuri t2 ON u3.tip = t2.tip "
                f"                 WHERE u3.id = {uid}) "
                f"ORDER BY ani_vechime ASC, t.salariu DESC LIMIT 20")
        trace.add('SELECT', select, 'colegi cu aceeași poziție și salariu mai mare')
        trace.add('BASE', base, 'self-join pe tip + subquery salariu propriu')
        return f"{select}\n{base}"

    # ──────────────────────────────────────────── STRUCTURĂ ORGANIZAȚIONALĂ ───

    def _build_my_manager(self, intent, ents, extra, user_id, trace):
        """Cine este managerul/supervizorul meu (din echipă sau taskes)."""
        uid = user_id or 0
        trace.add('NOTE', '', f'managerul userului {uid} via echipe.supervizor')
        select = ("SELECT CONCAT(sup.nume,' ',sup.prenume) AS manager, "
                  "d.nume_dep AS departament, t.denumire AS functie, "
                  "sup.email, sup.telefon, e.nume AS echipa")
        base = (f"FROM membrii_echipe me "
                f"JOIN echipe e ON me.id_echipa = e.id "
                f"JOIN useri sup ON e.supervizor = sup.id "
                f"LEFT JOIN departament d ON sup.id_dep = d.id_dep "
                f"LEFT JOIN tipuri t ON sup.tip = t.tip "
                f"WHERE me.id_ang = {uid} AND sup.id != {uid} "
                f"GROUP BY sup.id, sup.nume, sup.prenume, d.nume_dep, t.denumire, "
                f"sup.email, sup.telefon, e.nume "
                f"LIMIT 5")
        trace.add('SELECT', select, 'supervizorul echipei (manager direct)')
        trace.add('BASE', base, 'membrii_echipe → echipe.supervizor → useri')
        return f"{select}\n{base}"

    def _build_senior_employees(self, intent, ents, extra, user_id, trace):
        """Angajații seniori — tipuri.ierarhie ≤ 4 (director, manager, lead)."""
        trace.add('NOTE', '', 'seniori = tipuri.ierarhie <= 4 (1=CEO...4=manager)')
        dept_filter = ""
        if ents.department:
            dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
        select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                  "d.nume_dep AS departament, t.denumire AS functie, "
                  "t.ierarhie AS nivel_ierarhic, "
                  "FLOOR(DATEDIFF(CURDATE(), u.data_ang)/365) AS ani_vechime")
        base = (f"FROM useri u "
                f"JOIN tipuri t ON u.tip = t.tip "
                f"LEFT JOIN departament d ON u.id_dep = d.id_dep "
                f"WHERE IFNULL(u.activ, 1) != 0 AND u.username != 'test' "
                f"AND t.ierarhie <= 4 {dept_filter} "
                f"ORDER BY t.ierarhie ASC, u.data_ang ASC LIMIT 50")
        trace.add('SELECT', select, 'angajați cu ierarhie <= 4 (senior/lead/manager/dir)')
        trace.add('BASE', base, 'ierarhie 1=CEO, 2=VP, 3=Director, 4=Manager')
        return f"{select}\n{base}"

    def _build_same_position(self, intent, ents, extra, user_id, trace):
        """Angajații cu aceeași poziție (tip) ca userul curent."""
        uid = user_id or 0
        trace.add('NOTE', '', f'aceeași poziție ca user_id={uid}')
        select = ("SELECT CONCAT(u2.nume,' ',u2.prenume) AS coleg, "
                  "d.nume_dep AS departament, t.denumire AS pozitie, "
                  "FLOOR(DATEDIFF(CURDATE(), u2.data_ang)/365) AS ani_vechime")
        base = (f"FROM useri u "
                f"JOIN useri u2 ON u2.tip = u.tip "
                f"  AND u2.id != {uid} AND IFNULL(u2.activ, 1) != 0 "
                f"JOIN tipuri t ON u2.tip = t.tip "
                f"LEFT JOIN departament d ON u2.id_dep = d.id_dep "
                f"WHERE u.id = {uid} "
                f"ORDER BY d.nume_dep, u2.data_ang DESC LIMIT 30")
        trace.add('SELECT', select, 'angajați cu tipuri.tip identic cu al userului')
        trace.add('BASE', base, 'self-join useri pe u.tip = u2.tip')
        return f"{select}\n{base}"

    def _build_no_subordinates(self, intent, ents, extra, user_id, trace):
        """Angajații care nu sunt supervizori (nu apar în tasks.supervizor sau echipe.supervizor)."""
        trace.add('NOTE', '', 'angajați fără subordonați = nu sunt supervizori')
        if intent == 'count':
            select = "SELECT COUNT(*) AS angajati_fara_subordonati"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "t.ierarhie")
        base = ("FROM useri u "
                "LEFT JOIN departament d ON u.id_dep = d.id_dep "
                "LEFT JOIN tipuri t ON u.tip = t.tip "
                "WHERE IFNULL(u.activ, 1) != 0 AND u.username != 'test' "
                "AND u.id NOT IN (SELECT DISTINCT supervizor FROM echipe WHERE supervizor IS NOT NULL) "
                "AND u.id NOT IN (SELECT DISTINCT supervizor FROM tasks WHERE supervizor IS NOT NULL) "
                "ORDER BY t.ierarhie DESC, u.nume LIMIT 100")
        trace.add('SELECT', select, 'NOT IN supervizori din echipe + tasks')
        trace.add('BASE', base, 'dublu NOT IN pentru a exclude orice supervizor')
        return f"{select}\n{base}"

    def _build_promotions(self, intent, ents, extra, user_id, trace):
        """Numărul/lista de promovări (din historic_promovari)."""
        trace.add('NOTE', '', 'promovări din tabel historic_promovari')
        dept_filter = ""
        if ents.department:
            dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
        temporal_filter = "AND YEAR(ip.data_promovare) = YEAR(CURDATE())"
        if ents.temporal_sql:
            temporal_filter = f"AND {ents.temporal_sql.replace('c.start_c','ip.data_promovare')}"

        if intent == 'count':
            select = "SELECT COUNT(*) AS total_promovari"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, "
                      "tv.denumire AS pozitie_veche, tn.denumire AS pozitie_noua, "
                      "ip.tip_promovare, ip.data_promovare")
        base = (f"FROM istoric_promovari ip "
                f"JOIN useri u ON ip.id_ang = u.id "
                f"LEFT JOIN departament d ON u.id_dep = d.id_dep "
                f"LEFT JOIN tipuri tv ON ip.tip_vechi = tv.tip "
                f"LEFT JOIN tipuri tn ON ip.tip_nou = tn.tip "
                f"WHERE 1=1 {dept_filter} {temporal_filter} "
                f"ORDER BY ip.data_promovare DESC LIMIT 100")
        trace.add('SELECT', select, 'promovări cu detalii din/în ce poziție')
        trace.add('BASE', base, 'historic_promovari + tipuri vechi și noi')
        return f"{select}\n{base}"

    # ─────────────────────────────────────────────────────────────── MISC ──────

    def _build_work_hours_left(self, intent, ents, extra, user_id, trace):
        """Cât mai am până se termină programul (18:00)."""
        trace.add('NOTE', '', 'ore rămase = TIMESTAMPDIFF(MINUTE, NOW(), TIME 18:00)')
        end_hour = ents.work_end_hour
        select = (f"SELECT "
                  f"CASE WHEN HOUR(NOW()) >= {end_hour} THEN 'Programul s-a terminat!' "
                  f"ELSE CONCAT( "
                  f"  TIMESTAMPDIFF(MINUTE, NOW(), "
                  f"    CONCAT(DATE(NOW()), ' {end_hour:02d}:00:00')) DIV 60, "
                  f"  ' ore și ', "
                  f"  TIMESTAMPDIFF(MINUTE, NOW(), "
                  f"    CONCAT(DATE(NOW()), ' {end_hour:02d}:00:00')) MOD 60, "
                  f"  ' minute rămase până la {end_hour}:00') "
                  f"END AS timp_ramas, "
                  f"TIME_FORMAT(NOW(), '%H:%i') AS ora_curenta")
        trace.add('SELECT', select, f'TIMESTAMPDIFF până la {end_hour}:00')
        return f"{select}"

    def _build_leave_analytics(self, intent, ents, extra, user_id, trace):
        """În ultimii 3 ani, în ce lună și-au luat angajații cele mai multe zile de concediu."""
        trace.add('NOTE', '', 'analytics concedii: luna cu cele mai multe zile (3 ani)')
        select = ("SELECT MONTH(c.start_c) AS luna, "
                  "MONTHNAME(c.start_c) AS denumire_luna, "
                  "YEAR(c.start_c) AS an, "
                  "SUM(c.durata) AS total_zile, "
                  "COUNT(*) AS nr_cereri, "
                  "COUNT(DISTINCT c.id_ang) AS nr_angajati")
        base = ("FROM concedii c "
                "JOIN useri u ON c.id_ang = u.id "
                "WHERE c.start_c >= CURDATE() - INTERVAL 3 YEAR "
                "AND c.status = 2 "
                "AND u.username != 'test' "
                "GROUP BY YEAR(c.start_c), MONTH(c.start_c) "
                "ORDER BY total_zile DESC LIMIT 12")
        trace.add('SELECT', select, 'SUM(durata) GROUP BY lună+an, status=aprobat')
        trace.add('BASE', base, 'ultimii 3 ani, concedii aprobate, top 12 luni')
        return f"{select}\n{base}"

    def _build_remote_employees(self, intent, ents, extra, user_id, trace):
        """Câți angajați lucrează remote (via id_sediu sau locație specială)."""
        trace.add('NOTE', '',
                  'angajați remote: id_sediu IS NULL sau sediu cu "remote" în nume')
        if intent == 'count':
            select = "SELECT COUNT(*) AS angajati_remote"
        else:
            select = ("SELECT CONCAT(u.nume,' ',u.prenume) AS angajat, "
                      "d.nume_dep AS departament, t.denumire AS functie, "
                      "s.localitate AS sediu")
        base = ("FROM useri u "
                "LEFT JOIN departament d ON u.id_dep = d.id_dep "
                "LEFT JOIN tipuri t ON u.tip = t.tip "
                "LEFT JOIN sedii s ON u.id_sediu = s.id_sediu "
                "WHERE IFNULL(u.activ, 1) != 0 AND u.username != 'test' "
                "AND (u.id_sediu IS NULL OR UPPER(s.localitate) LIKE '%REMOTE%' "
                "     OR UPPER(s.localitate) LIKE '%ACASA%') "
                "ORDER BY d.nume_dep, u.nume LIMIT 100")
        trace.add('SELECT', select, 'id_sediu IS NULL sau sediu remote/acasă')
        trace.add('BASE', base, 'sedii.localitate LIKE remote/acasa + activ=1')
        return f"{select}\n{base}"

    # ──────────────────────────────────────── FLUTURAȘ / DEDUCERI SALARIU ────

    def _build_salary_deductions(self, intent, ents, extra, user_id, trace):
        """
        "Care sunt deducerile din salariul meu?"
        Reproduce exact logica de calcul din fluturas.jsp:
          salariu_brut = salariu_baza + spor - penalizare
          CAS  = brut * 25%
          CASS = brut * 10%
          impozit = (brut - CAS - CASS) * 10%
          net  = brut - CAS - CASS - impozit

        Sporurile și penalizările active sunt din tabelele
        istoric_sporuri/tipuri_sporuri și istoric_penalizari/tipuri_penalizari.
        """
        uid = user_id or 0
        trace.add('NOTE', '',
                  f'deduceri salariu user_id={uid} — reproduce logica fluturas.jsp')

        # Subquery spor activ (dacă există, altfel 0)
        spor_subq = (f"(SELECT IFNULL(ts.procent, 0) "
                     f" FROM istoric_sporuri isp "
                     f" JOIN tipuri_sporuri ts ON isp.tip_spor = ts.id "
                     f" WHERE isp.id_ang = {uid} "
                     f" AND isp.data_start <= CURDATE() AND isp.data_final >= CURDATE() "
                     f" LIMIT 1)")

        spor_den  = (f"(SELECT IFNULL(ts.denumire, '-') "
                     f" FROM istoric_sporuri isp "
                     f" JOIN tipuri_sporuri ts ON isp.tip_spor = ts.id "
                     f" WHERE isp.id_ang = {uid} "
                     f" AND isp.data_start <= CURDATE() AND isp.data_final >= CURDATE() "
                     f" LIMIT 1)")

        pen_subq  = (f"(SELECT IFNULL(tp.procent, 0) "
                     f" FROM istoric_penalizari ipp "
                     f" JOIN tipuri_penalizari tp ON ipp.tip_penalizare = tp.id "
                     f" WHERE ipp.id_ang = {uid} "
                     f" AND ipp.data_start <= CURDATE() AND ipp.data_final >= CURDATE() "
                     f" LIMIT 1)")

        pen_den   = (f"(SELECT IFNULL(tp.denumire, '-') "
                     f" FROM istoric_penalizari ipp "
                     f" JOIN tipuri_penalizari tp ON ipp.tip_penalizare = tp.id "
                     f" WHERE ipp.id_ang = {uid} "
                     f" AND ipp.data_start <= CURDATE() AND ipp.data_final >= CURDATE() "
                     f" LIMIT 1)")

        # Expresii calculate, exact ca în JSP
        brut_expr = (f"t.salariu "
                     f"+ t.salariu * {spor_subq} / 100 "
                     f"- t.salariu * {pen_subq} / 100")

        select = (
            f"SELECT "
            f"  CONCAT(u.nume,' ',u.prenume) AS angajat, "
            f"  t.denumire AS functie, "
            f"  d.nume_dep AS departament, "
            f"  t.salariu AS salariu_baza, "
            # spor
            f"  {spor_den} AS tip_spor, "
            f"  {spor_subq} AS procent_spor, "
            f"  ROUND(t.salariu * {spor_subq} / 100) AS valoare_spor, "
            # penalizare
            f"  {pen_den} AS tip_penalizare, "
            f"  {pen_subq} AS procent_penalizare, "
            f"  ROUND(t.salariu * {pen_subq} / 100) AS valoare_penalizare, "
            # brut
            f"  ROUND({brut_expr}) AS salariu_brut, "
            # deduceri (CAS, CASS, impozit) — exact formulele din JSP
            f"  ROUND(({brut_expr}) * 0.25) AS CAS_25_proc, "
            f"  ROUND(({brut_expr}) * 0.10) AS CASS_10_proc, "
            f"  ROUND((({brut_expr}) - ({brut_expr})*0.25 - ({brut_expr})*0.10) * 0.10) AS impozit_10_proc, "
            # net
            f"  ROUND(({brut_expr}) "
            f"    - ({brut_expr})*0.25 "
            f"    - ({brut_expr})*0.10 "
            f"    - (({brut_expr})*0.65)*0.10 "
            f"  ) AS salariu_net"
        )

        base = (f"FROM useri u "
                f"JOIN tipuri t ON u.tip = t.tip "
                f"JOIN departament d ON u.id_dep = d.id_dep "
                f"WHERE u.id = {uid}")

        trace.add('SELECT', select[:80], 'brut=baza+spor-penalizare, deduceri CAS/CASS/impozit, net')
        trace.add('BASE', base, f'user_id={uid}')
        trace.add('NOTE', '', 'formule identice cu fluturas.jsp: CAS=25%, CASS=10%, impozit=(brut-CAS-CASS)*10%')
        return f"{select}\n{base}"

    def _build_salary_avg_net(self, intent, ents, extra, user_id, trace):
        """
        "Ce salariu au angajații în medie atât brut cât și net?"
        Calculăm pentru fiecare angajat brut și net (cu sporuri/penalizări active)
        și facem media. Departament opțional.

        Notă: sporurile/penalizările sunt per angajat, nu per tip.
        Folosim LEFT JOIN cu condiție de dată activă.
        """
        trace.add('NOTE', '', 'medie brut+net per angajat — reproduce logica fluturas.jsp')

        dept_filter = ""
        if ents.department:
            dept_filter = f"AND UPPER(d.nume_dep) LIKE UPPER('%{ents.department}%')"
            trace.add('WHERE', dept_filter.strip(), f"departament: '{ents.department}'")

        # Subquery inline per angajat care calculează brut și net
        inner = (
            f"SELECT "
            f"  u.id, CONCAT(u.nume,' ',u.prenume) AS angajat, "
            f"  d.nume_dep AS departament, t.denumire AS functie, "
            f"  t.salariu AS baza, "
            f"  IFNULL(ts.procent, 0) AS proc_spor, "
            f"  IFNULL(tp2.procent, 0) AS proc_pen, "
            # brut
            f"  ROUND(t.salariu * (1 + IFNULL(ts.procent,0)/100 - IFNULL(tp2.procent,0)/100)) AS brut "
            f"FROM useri u "
            f"JOIN tipuri t ON u.tip = t.tip "
            f"JOIN departament d ON u.id_dep = d.id_dep "
            f"LEFT JOIN ("
            f"  SELECT isp.id_ang, ts2.procent "
            f"  FROM istoric_sporuri isp JOIN tipuri_sporuri ts2 ON isp.tip_spor=ts2.id "
            f"  WHERE isp.data_start <= CURDATE() AND isp.data_final >= CURDATE()"
            f") ts ON ts.id_ang = u.id "
            f"LEFT JOIN ("
            f"  SELECT ipp.id_ang, tp3.procent "
            f"  FROM istoric_penalizari ipp JOIN tipuri_penalizari tp3 ON ipp.tip_penalizare=tp3.id "
            f"  WHERE ipp.data_start <= CURDATE() AND ipp.data_final >= CURDATE()"
            f") tp2 ON tp2.id_ang = u.id "
            f"WHERE IFNULL(u.activ, 1) != 0 AND u.username != 'test' {dept_filter}"
        )

        if ents.department:
            # Media per departament specificat
            select = (
                f"SELECT departament, functie, "
                f"ROUND(AVG(baza)) AS salariu_baza_mediu, "
                f"ROUND(AVG(brut)) AS salariu_brut_mediu, "
                f"ROUND(AVG(brut * 0.65 * 0.90)) AS salariu_net_mediu, "
                f"COUNT(*) AS nr_angajati "
                f"FROM ({inner}) AS calc "
                f"GROUP BY departament, functie "
                f"ORDER BY salariu_brut_mediu DESC"
            )
        else:
            # Media globală + per departament
            select = (
                f"SELECT departament, "
                f"ROUND(AVG(baza)) AS salariu_baza_mediu, "
                f"ROUND(AVG(brut)) AS salariu_brut_mediu, "
                f"ROUND(AVG(brut * 0.65 * 0.90)) AS salariu_net_mediu, "
                f"COUNT(*) AS nr_angajati "
                f"FROM ({inner}) AS calc "
                f"GROUP BY departament "
                f"ORDER BY salariu_brut_mediu DESC"
            )

        trace.add('SELECT', select[:80], 'AVG(brut) și AVG(net=brut*0.65*0.90) per departament')
        trace.add('NOTE', '', 'net = brut*(1-CAS25%)*(1-CASS10%)*(1-imp10%) = brut*0.75*0.90*0.90 ≈ brut*0.6075')
        return select



class ExampleBasedMatcher:
    def __init__(self, examples, threshold=0.25):
        self.examples = examples
        self.threshold = threshold
        self.example_texts = [normalize(ex['query']) for ex in examples]
        self.vectorizer = TfidfVectorizer(analyzer='word', ngram_range=(1,2),
                                         min_df=1, sublinear_tf=True)
        self.example_vectors = self.vectorizer.fit_transform(self.example_texts)
        print(f"[NLQ] Matcher: {len(examples)} exemple, "
              f"vocabular {len(self.vectorizer.vocabulary_)} termeni")

    def match(self, query):
        q_norm = normalize(query)
        q_vec = self.vectorizer.transform([q_norm])
        sims = cosine_similarity(q_vec, self.example_vectors)[0]
        best_idx = int(np.argmax(sims))
        best_score = float(sims[best_idx])
        best = self.examples[best_idx]

        return {
            'success': best_score >= self.threshold,
            'confidence': best_score,
            'matched_example': best['query'],
            'intent': best['intent'],
            'entity': best['entity'],
            'extra': best.get('extra', {}),
        }


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 7 — NLQ ENGINE (orchestrare)
# ══════════════════════════════════════════════════════════════════════════════

class NLQEngine:
    def __init__(self):
        self.matcher = ExampleBasedMatcher(LABELED_EXAMPLES, threshold=0.25)
        self.builder = QueryBuilder()
        print("[NLQ] Engine v2 gata.\n")

    def process(self, query: str, current_user_id: Optional[int] = None,
                verbose: bool = True) -> dict:
        """
        Procesează query-ul și returnează SQL + debug complet.

        Pipeline:
          1. Normalizare text
          2. QuestionWordAnalyzer → override intent/entity dacă e cazul
          3. TF-IDF Matcher → intent + entity din exemple
          4. Merge: override-urile QW au prioritate față de TF-IDF
          5. ExtractEntities → departament, temporal, status etc.
          6. QueryBuilder → SQL din piese

        verbose=True → afișează tot în consolă
        """
        q_norm = normalize(query)

        # ── Pasul 1: Extragere entități (include QW analysis intern) ──
        ents = extract_entities(q_norm)

        # ── Pasul 2: TF-IDF Matching ──
        match = self.matcher.match(query)

        # ── Pasul 3: Merge intent + entity ──
        # Override-urile din QuestionWordAnalyzer au prioritate
        # dacă au confidence mai mare decât pragul nostru (0.7)
        final_intent = match['intent']
        final_entity = match['entity']
        intent_source = f"TF-IDF (conf={match['confidence']:.2f})"
        entity_source = f"TF-IDF (conf={match['confidence']:.2f})"

        if ents.qw_forced_intent and ents.qw_confidence >= 0.70:
            final_intent = ents.qw_forced_intent
            intent_source = f"QuestionWord '{ents.question_word}' (conf={ents.qw_confidence:.2f})"

        if ents.qw_forced_entity and ents.qw_confidence >= 0.70:
            final_entity = ents.qw_forced_entity
            entity_source = f"QuestionWord '{ents.question_word}' (conf={ents.qw_confidence:.2f})"

        # ── Pasul 3b: Override semantic pentru entitățile noi ──────────────────
        # QWA și TF-IDF nu știu de entitățile adăugate recent.
        # Detectăm pattern-uri specifice din flags și le punem cu prioritate maximă.
        semantic_override = None

        if ents.is_team_query:
            q_lower = q_norm
            if any(w in q_lower for w in ['concediu', 'concedii']):
                semantic_override = ('team_leave', 'echipă + concediu → team_leave')
            elif any(w in q_lower for w in ['salariu', 'salarii', 'castig', 'venit']):
                semantic_override = ('team_salary', 'echipă + salariu → team_salary')
            elif any(w in q_lower for w in ['membrii', 'lucreaza', 'cine', 'angajati']):
                semantic_override = ('team_members', 'echipă + cine → team_members')

        if semantic_override is None:
            if any(w in q_norm for w in ['managerul meu', 'seful meu', 'supervizorul meu',
                                          'managerul direct', 'sef direct']):
                semantic_override = ('my_manager', 'manager/sef meu → my_manager')

            elif 'subaltern' in q_norm or 'subordonat' in q_norm:
                semantic_override = ('no_subordinates', 'subaltern/subordonat → no_subordinates')

            elif any(w in q_norm for w in ['remote', 'acasa', 'de acasa', 'work from home']):
                semantic_override = ('remote_employees', 'remote/acasa → remote_employees')

            elif any(w in q_norm for w in ['promotii', 'promovari', 'promovat', 'promovare']):
                semantic_override = ('promotions', 'promovare → promotions')

            elif any(w in q_norm for w in ['pana se termina programul', 'pana la ora',
                                            'pana la sfarsit', 'sfarsit program']):
                semantic_override = ('work_hours_left', 'program → work_hours_left')

            elif (ents.salary_agg_personal or
                  any(w in q_norm for w in ['pozitia mea', 'functia mea', 'rolul meu'])):
                semantic_override = ('position_salary', 'poziția mea → position_salary')

            elif ('aceeasi pozitie' in q_norm and 'salariu mai mare' in q_norm):
                semantic_override = ('salary_comparison', 'aceeași poziție + salariu mai mare → salary_comparison')

            elif 'aceeasi pozitie ca mine' in q_norm or 'acelasi statut ca mine' in q_norm:
                semantic_override = ('same_position', 'aceeași poziție ca mine → same_position')

            elif any(w in q_norm for w in ['seniori', 'senior', 'angajati seniori']):
                semantic_override = ('senior_employees', 'seniori → senior_employees')

            elif (('concediu medical' in q_norm or 'concedii medicale' in q_norm or
                   (ents.leave_type and ents.is_personal)) and
                  any(w in q_norm for w in ['am avut', 'am luat', 'am folosit', 'am consumat',
                                             'am stat', 'mi-am luat'])):
                semantic_override = ('leave_personal_stats', 'concediu tip + am avut → leave_personal_stats')

            elif any(w in q_norm for w in ['urmatorul concediu', 'urmatoarea vacanta',
                                            'cand iau concediu', 'urmatorul meu concediu']):
                semantic_override = ('next_leave', 'următorul concediu → next_leave')

            elif any(w in q_norm for w in ['angajari', 'angajati noi', 'recrutari']):
                semantic_override = ('hiring_stats', 'angajări → hiring_stats')

            elif any(w in q_norm for w in ['concediat', 'concediati', 'dat afara', 'inactiv']):
                semantic_override = ('termination_stats', 'concedieri → termination_stats')

            elif 'workload' in q_norm or ('taskuri' in q_norm and 'departament' in q_norm
                                           and any(w in q_norm for w in ['cel mai', 'maxim'])):
                semantic_override = ('task_stats', 'workload departament → task_stats')

            elif ('medie' in q_norm or 'in medie' in q_norm) and 'taskuri' in q_norm:
                semantic_override = ('task_stats', 'taskuri medie → task_stats')

            elif (('brut' in q_norm and 'net' in q_norm) or
                  ('deduceri' in q_norm) or ('retineri' in q_norm) or
                  ('taxe' in q_norm and 'salariu' in q_norm) or
                  ('cas' in q_norm and 'cass' in q_norm) or
                  ('impozit' in q_norm and 'salariu' in q_norm)):
                # "taxe din salariu" / "deduceri" → mereu personal (nimeni nu întreabă pt alții)
                # "brut și net" cu persoană → personal; fără persoană + medie → avg_net
                is_avg = any(w in q_norm for w in ['medie', 'mediu', 'angajatii', 'angajatilor',
                                                    'toti', 'firma', 'companie'])
                if is_avg and not ents.is_personal:
                    semantic_override = ('salary_avg_net', 'brut+net medie → salary_avg_net')
                else:
                    semantic_override = ('salary_deductions',
                                         'taxe/deduceri/brut+net personal → salary_deductions')

            elif (('medie' in q_norm or 'mediu' in q_norm) and
                  any(w in q_norm for w in ['net', 'brut', 'salariu net', 'salariu brut'])):
                semantic_override = ('salary_avg_net', 'salariu mediu brut/net → salary_avg_net')

            elif ('ultimii 3 ani' in q_norm or 'in ce luna' in q_norm) and 'concediu' in q_norm:
                semantic_override = ('leave_analytics', 'analytics concedii 3 ani → leave_analytics')

        if semantic_override:
            final_entity, override_reason = semantic_override
            entity_source = f"semantic override ({override_reason})"

        if verbose:
            print(f"\n{'═'*62}")
            print(f"  QUERY:   \"{query}\"")
            print(f"  NORM:    \"{q_norm}\"")
            print(f"{'─'*62}")

            # Secțiunea QuestionWordAnalyzer
            print(f"  ANALIZĂ INTEROGATIV:")
            if ents.question_word:
                print(f"    cuvânt:  '{ents.question_word}'")
                print(f"    focus:   {ents.focus or '—'}")
                print(f"    motiv:   {ents.qw_reason}")
                if ents.qw_forced_intent:
                    mark = "✅ aplicat" if ents.qw_confidence >= 0.70 else "⚠️  ignorat (conf < 0.70)"
                    print(f"    intent:  {ents.qw_forced_intent} [{mark}]")
                if ents.qw_forced_entity:
                    mark = "✅ aplicat" if ents.qw_confidence >= 0.70 else "⚠️  ignorat (conf < 0.70)"
                    print(f"    entity:  {ents.qw_forced_entity} [{mark}]")
            else:
                print(f"    {ents.qw_reason}")

            print(f"{'─'*62}")
            print(f"  TF-IDF MATCH:")
            print(f"    exemplu: \"{match['matched_example']}\"")
            print(f"    conf:    {match['confidence']:.2f}  "
                  f"({'✅' if match['success'] else '❌ sub prag'})")
            print(f"{'─'*62}")
            print(f"  DECIZIE FINALĂ:")
            print(f"    intent:  {final_intent}  ← {intent_source}")
            print(f"    entity:  {final_entity}  ← {entity_source}")
            print(f"{'─'*62}")
            print(f"  ENTITĂȚI DETECTATE:")
            print(f"    {ents.summary()}")

        if not match['success'] and not ents.qw_forced_entity:
            if verbose:
                print(f"\n  ⚠️  TF-IDF sub prag și nicio entitate forțată de interogativ.")
                print(f"{'═'*62}")
            return {
                'success': False,
                'sql': None,
                'confidence': match['confidence'],
                'message': (f"Nu am înțeles întrebarea "
                            f"(TF-IDF conf: {match['confidence']:.2f}). "
                            "Încearcă să reformulezi."),
                'debug': {
                    'normalized': q_norm,
                    'best_match': match['matched_example'],
                    'entities': ents.summary(),
                    'qw_analysis': ents.qw_reason,
                }
            }

        # ── Pasul 4: Construiește SQL ──
        sql, trace = self.builder.build(
            final_intent, final_entity,
            ents, match.get('extra', {}), current_user_id
        )

        if verbose:
            print(trace.format())
            if sql:
                print(f"\n  SQL FINAL:\n")
                for line in sql.split('\n'):
                    print(f"    {line}")
            print(f"{'═'*62}")

        if not sql:
            return {
                'success': False,
                'sql': None,
                'message': 'Nu am putut genera SQL pentru această combinație.',
            }

        return {
            'success':         True,
            'sql':             sql,
            'intent':          final_intent,
            'entity':          final_entity,
            'confidence':      match['confidence'],
            'entities_found':  ents.summary(),
            'matched_example': match['matched_example'],
            'qw_analysis': {
                'question_word':  ents.question_word,
                'focus':          ents.focus,
                'forced_intent':  ents.qw_forced_intent,
                'forced_entity':  ents.qw_forced_entity,
                'confidence':     ents.qw_confidence,
                'reason':         ents.qw_reason,
            },
            'build_trace': list(trace.pieces),
        }


# ══════════════════════════════════════════════════════════════════════════════
# SECȚIUNEA 8 — MODURI DE RULARE
#
# python3 nlq_engine_v2.py            → test batch + CLI interactiv
# python3 nlq_engine_v2.py --server   → server Flask pe portul 5050
# python3 nlq_engine_v2.py --cli      → doar CLI interactiv, fără test batch
#
# Endpoint-uri server:
#   POST /nlq          → { "query": "...", "user_id": 1 }
#   GET  /health       → status server
#   GET  /examples     → lista exemplelor etichetate
# ══════════════════════════════════════════════════════════════════════════════

# ─── query-uri pentru test batch ─────────────────────────────────────────────
TEST_QUERIES = [
    # ── clasice ───────────────────────────────────────────────────────────────
    ("câți angajați sunt în IT",                            1),
    ("arată-mi departamentele",                             1),
    ("concediile aprobate din HR din luna trecută",         1),
    ("câte concedii în așteptare sunt în marketing",        1),
    ("câți oameni lucrează în departamentul de tehnologie", 1),
    ("membrii echipei de resurse umane",                    1),

    # ── câți/câte → COUNT forțat ──────────────────────────────────────────────
    ("câți directori are firma",                            1),
    ("câte departamente există",                            1),
    ("câte adeverințe sunt neaprobate",                     1),

    # ── cine → employee forțat ────────────────────────────────────────────────
    ("cine este în concediu astăzi",                        1),
    ("cine lucrează în juridic",                            1),

    # ── care + context → entitate dedusă ──────────────────────────────────────
    ("care este salariul meu",                             42),
    ("care este vechimea mea la firmă",                    42),
    ("care este rolul lui Vasile",                          1),
    ("care departament are cei mai mulți angajați",         1),

    # ── pozitie/rang detectat direct ──────────────────────────────────────────
    ("rangul angajaților din IT",                           1),

    # ── personal ──────────────────────────────────────────────────────────────
    ("câte zile libere mai am eu",                         42),
    ("taskurile mele neterminate",                         42),

    # ── edge case ─────────────────────────────────────────────────────────────
    ("vreme frumoasă afară",                             None),
]


def run_test_batch(engine):
    print("\n" + "═"*60)
    print("  TEST BATCH — NLQ Engine v2")
    print("═"*60)
    ok = 0
    for query, uid in TEST_QUERIES:
        result = engine.process(query, current_user_id=uid, verbose=True)
        if result['success']:
            ok += 1
    print(f"\n  Rezultat: {ok}/{len(TEST_QUERIES)} query-uri procesate cu succes.\n")


def run_cli(engine):
    """CLI interactiv — citește întrebări de la tastatură."""
    print("\n" + "═"*60)
    print("  MOD CLI INTERACTIV")
    print("  Scrie o întrebare în română. 'exit' pentru a ieși.")
    print("  user_id implicit: 1  (schimbă cu  :uid=42 la sfârșitul întrebării)")
    print("═"*60)

    while True:
        try:
            raw = input("\nTu: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nLa revedere!")
            break

        if not raw:
            continue
        if raw.lower() in ('exit', 'quit', 'q'):
            print("La revedere!")
            break

        # Suport pentru :uid=42 la finalul întrebării
        # ex: "câte zile am eu :uid=42"
        uid = 1
        query = raw
        uid_match = re.search(r':uid=(\d+)\s*$', raw)
        if uid_match:
            uid = int(uid_match.group(1))
            query = raw[:uid_match.start()].strip()
            print(f"  (user_id setat la {uid})")

        engine.process(query, current_user_id=uid, verbose=True)


def run_server(engine, port=5050):
    """
    Server Flask — primește întrebări via HTTP POST JSON și returnează SQL.

    Endpoint principal:
      POST /nlq
      Body: { "query": "câți angajați sunt în IT?", "user_id": 1 }

      Response succes:
      {
        "success": true,
        "sql": "SELECT COUNT(*) ...",
        "intent": "count",
        "entity": "employee",
        "confidence": 0.79,
        "entities_found": "departament='IT'",
        "matched_example": "cati angajati sunt in firma",
        "build_trace": [
          {"type": "BASE", "sql": "FROM useri u ...", "reason": "..."},
          {"type": "WHERE", "sql": "u.username != 'test'", "reason": "..."},
          ...
        ]
      }

      Response eșec:
      {
        "success": false,
        "message": "Nu am înțeles întrebarea (confidence: 0.00).",
        "confidence": 0.00
      }

    Cum apelezi din JavaScript (async fetch):
      const resp = await fetch('http://localhost:5050/nlq', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: textulIntrebarii, user_id: userId })
      });
      const data = await resp.json();
      if (data.success) { console.log(data.sql); }
    """
    try:
        from flask import Flask, request, jsonify
        from flask_cors import CORS
    except ImportError:
        print("Flask lipsește. Instalează cu:  pip install flask flask-cors")
        return

    app = Flask(__name__)
    CORS(app)  # permite fetch din JSP/HTML pe alt port

    # ── POST /nlq ─────────────────────────────────────────────────────────────
    @app.route('/nlq', methods=['POST'])
    def nlq_endpoint():
        data = request.get_json(silent=True)
        if not data:
            return jsonify({'success': False,
                            'message': 'Body-ul trebuie să fie JSON.'}), 400

        query   = data.get('query', '').strip()
        user_id = data.get('user_id')        # poate fi None
        verbose = data.get('verbose', False) # optional: afișează trace în consolă

        if not query:
            return jsonify({'success': False,
                            'message': 'Câmpul "query" este obligatoriu.'}), 400

        # Procesăm — verbose=True afișează trace-ul în consola serverului
        result = engine.process(query, current_user_id=user_id, verbose=verbose)

        # build_trace e deja o listă de dict-uri, perfect pentru JSON
        return jsonify(result)

    # ── GET /health ───────────────────────────────────────────────────────────
    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({
            'status': 'ok',
            'examples': len(LABELED_EXAMPLES),
            'vocabulary': len(engine.matcher.vectorizer.vocabulary_),
            'threshold': engine.matcher.threshold,
        })

    # ── GET /examples ─────────────────────────────────────────────────────────
    @app.route('/examples', methods=['GET'])
    def list_examples():
        """Returnează toate exemplele etichetate — util pentru debugging."""
        return jsonify({
            'count': len(LABELED_EXAMPLES),
            'examples': LABELED_EXAMPLES
        })

    # ── Pornire server ────────────────────────────────────────────────────────
    print(f"\n{'═'*60}")
    print(f"  NLQ Server pornit pe http://localhost:{port}")
    print(f"  Endpoint:  POST http://localhost:{port}/nlq")
    print(f"  Health:    GET  http://localhost:{port}/health")
    print(f"  Examples:  GET  http://localhost:{port}/examples")
    print(f"{'─'*60}")
    print(f"  Exemplu curl:")
    print(f'  curl -X POST http://localhost:{port}/nlq \\')
    print(f'       -H "Content-Type: application/json" \\')
    print(f'       -d \'{{"query": "cati angajati sunt in IT", "user_id": 1}}\'')
    print(f"{'═'*60}\n")

    app.run(host='0.0.0.0', port=port, debug=False)


# ─── entry point ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='NLQ Engine v2 — HR Assistant')
    parser.add_argument('--server', action='store_true',
                        help='Pornește serverul Flask (POST /nlq)')
    parser.add_argument('--cli',    action='store_true',
                        help='Doar modul CLI interactiv, fără test batch')
    parser.add_argument('--port',   type=int, default=5050,
                        help='Portul serverului Flask (default: 5050)')
    parser.add_argument('--no-test', action='store_true',
                        help='Sare peste test batch în modul default')
    args = parser.parse_args()

    engine = NLQEngine()

    if args.server:
        # Modul server HTTP
        run_server(engine, port=args.port)

    elif args.cli:
        # Doar CLI, fără test batch
        run_cli(engine)

    else:
        # Default: test batch + CLI interactiv
        if not args.no_test:
            run_test_batch(engine)
        run_cli(engine)