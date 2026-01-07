# Africa-polis

## 📊 Analyse de l'Urbanisation Africaine

Ce dépôt contient un script Stata complet pour l'analyse des modèles d'urbanisation en Afrique, utilisant le jeu de données Africa-polis. Le projet produit des tabulations et des graphiques pour étudier les dynamiques de population urbaine et rurale à travers le continent africain.

---

## 📋 Table des Matières

- [Description du Projet](#-description-du-projet)
- [Structure du Dépôt](#-structure-du-dépôt)
- [Prérequis](#-prérequis)
- [Source des Données](#-source-des-données)
- [Guide d'Utilisation](#-guide-dutilisation)
- [Sections d'Analyse](#-sections-danalyse)
- [Fichiers de Sortie](#-fichiers-de-sortie)
- [Graphiques Générés](#-graphiques-générés)
- [Variables Clés](#-variables-clés)
- [Méthodologie](#-méthodologie)

---

## 🌍 Description du Projet

**Africa-polis** est un outil d'analyse statistique qui examine les tendances d'urbanisation en Afrique pour les années **2000**, **2025** et **2050**. L'analyse couvre :

1. **Répartition urbaine/rurale** : Analyse des parts de population urbaine et rurale aux niveaux continental, régional et par pays
2. **Distribution par classe de taille** : Classification des agglomérations urbaines selon leur population (10K-500K, 500K-1M, 1M-3M, 3M-5M, 5M-10M, 10M+)
3. **Analyse des dynamiques** : Taux de croissance et changements absolus de l'urbanisation
4. **Disparités régionales** : Comparaison des écarts d'urbanisation entre et au sein des régions

---

## 📁 Structure du Dépôt

```
Africa-polis/
├── README.md                         # Documentation du projet
├── Stata_workbook.xlsx               # Données source (agglomérations africaines)
└── africa_urbanization_analysis.do   # Script Stata principal
```

---

## ⚙️ Prérequis

### Logiciel Requis
- **Stata 16** (ou version ultérieure recommandée, versions antérieures non testées)

### Modules Stata
Le script utilise uniquement des commandes Stata natives. Aucun package externe n'est nécessaire.

### Configuration
1. Clonez ce dépôt
2. Ouvrez Stata
3. Définissez le répertoire de travail vers le dossier du projet :
   ```stata
   cd "/chemin/vers/Africa-polis"
   ```

---

## 📊 Source des Données

### Fichier de Données : `Stata_workbook.xlsx`

Le fichier Excel contient les données des agglomérations urbaines africaines avec les informations suivantes :

| Variable | Description |
|----------|-------------|
| `pays` | Nom du pays |
| `AU_Regions` | Région de l'Union Africaine |
| `Agglomeration_ID` | Identifiant unique de l'agglomération |
| `Upop2000`, `Upop2025`, `Upop2050` | Population urbaine par année |
| `TPOP2000`, `TPOP2025`, `TPOP2050` | Population totale par année |
| `CPopulation_YYYY_ClassRange` | Classification par classe de taille (ex: `CPopulation_2000_10to500`, `CPopulation_2025_500to1M`) |

### Années Analysées
- **2000** : Année de référence historique
- **2025** : Projection à moyen terme
- **2050** : Projection à long terme

---

## 🚀 Guide d'Utilisation

### Exécution du Script

1. **Ouvrir Stata** et définir le répertoire de travail :
   ```stata
   cd "/chemin/vers/Africa-polis"
   ```

2. **Exécuter le script** :
   ```stata
   do "africa_urbanization_analysis.do"
   ```

3. **Consulter les résultats** :
   - Un fichier log `africa_urbanization_analysis.log` sera créé
   - Les graphiques seront exportés en format PNG
   - Les données seront exportées en formats `.dta` et `.xlsx`

### Options de Configuration

Vous pouvez modifier le schéma graphique dans le script :
```stata
set scheme s2color  // Schéma par défaut
// Alternatives : s1mono, economist, sj
```

---

## 📈 Sections d'Analyse

### Section 1 : Import et Préparation des Données

| Opération | Description |
|-----------|-------------|
| Import Excel | Chargement des données depuis `Stata_workbook.xlsx` |
| Renommage | Standardisation des noms de variables |
| Encodage | Création de variables numériques pour les graphiques |
| Labels | Attribution d'étiquettes aux classes de taille |

### Section 2 : Analyse Urbain vs Rural

**2.1 Niveau Continental**
- Calcul des parts urbaines et rurales pour l'ensemble de l'Afrique
- Graphique : Évolution temporelle des parts urbaines/rurales

**2.2 Niveau Régional**
- Agrégation par région de l'Union Africaine
- Comparaison des taux d'urbanisation entre régions
- Graphique : Parts urbaines par région (2000, 2025, 2050)

**2.3 Niveau Pays**
- Analyse détaillée par pays
- Classement des pays les plus et moins urbanisés
- Graphiques : Top 10 pays les plus/moins urbanisés en 2050

### Section 3 : Distribution par Classe de Taille

| Classe | Population |
|--------|------------|
| 1 | 10K - 500K |
| 2 | 500K - 1M |
| 3 | 1M - 3M |
| 4 | 3M - 5M |
| 5 | 5M - 10M |
| 6 | 10M+ (mégapoles) |

**Analyses effectuées :**
- Nombre d'agglomérations par classe pour chaque année
- Distribution régionale des classes de taille
- Identification des pays avec des mégapoles (10M+)

### Section 4 : Analyse des Dynamiques

**4.1 Croissance de l'Urbanisation**
- Changements absolus (points de pourcentage)
- Taux de croissance relatifs
- Identification des patterns d'accélération/décélération

**4.2 Dynamiques des Classes de Taille**
- Évolution du nombre d'agglomérations par classe
- Taux de croissance par catégorie de taille

**4.3 Comparaison Régionale**
- Changements par région et par classe
- Identification des régions avec la plus forte croissance

### Section 5 : Analyse Comparative

- Métriques de disparité régionale (plage, coefficient de variation)
- Disparités intra-régionales entre pays
- Identification des extrêmes (pays les plus/moins urbanisés par région)

### Section 6 : Tableaux Récapitulatifs

- Synthèse des indicateurs continentaux
- Export des résultats finaux

---

## 📤 Fichiers de Sortie

### Fichiers de Données (.dta)

| Fichier | Description |
|---------|-------------|
| `africa_polis_prepared.dta` | Données préparées avec variables transformées |
| `regional_urban_rural.dta` | Données urbaines/rurales par région |
| `country_urban_rural.dta` | Données urbaines/rurales par pays |
| `continent_size_class_data.dta` | Distribution des classes de taille (continental) |
| `region_size_class_data.dta` | Distribution des classes de taille (régional) |
| `country_size_class_data.dta` | Distribution des classes de taille (pays) |
| `regional_dynamics.dta` | Dynamiques de croissance régionales |
| `country_dynamics.dta` | Dynamiques de croissance par pays |
| `size_class_dynamics.dta` | Dynamiques des classes de taille |
| `regional_class_dynamics.dta` | Dynamiques régionales par classe |

### Fichiers Excel (.xlsx)

| Fichier | Description |
|---------|-------------|
| `country_urban_rural.xlsx` | Parts urbaines/rurales par pays |
| `country_size_class.xlsx` | Classes de taille par pays |
| `continental_summary.xlsx` | Synthèse continentale |

### Fichiers CSV

| Fichier | Description |
|---------|-------------|
| `analysis_results.csv` | Résultats d'analyse exportés |

### Fichier Log

| Fichier | Description |
|---------|-------------|
| `africa_urbanization_analysis.log` | Journal complet de l'exécution |

---

## 📊 Graphiques Générés

| Fichier | Description |
|---------|-------------|
| `continent_urban_rural.png` | Parts urbaines/rurales continentales |
| `region_urban_share.png` | Parts urbaines par région |
| `top10_urban_2050.png` | 10 pays les plus urbanisés (2050) |
| `bottom10_urban_2050.png` | 10 pays les moins urbanisés (2050) |
| `continent_size_class.png` | Distribution des classes de taille (continental) |
| `region_size_class_2050.png` | Classes de taille par région (2050) |
| `region_urban_dynamics.png` | Dynamiques d'urbanisation régionales |
| `top15_urbanizing.png` | 15 pays avec urbanisation la plus rapide |
| `size_class_growth_abs.png` | Croissance absolue par classe |
| `size_class_growth_pct.png` | Croissance relative par classe |

---

## 🔑 Variables Clés

### Variables de Population

| Variable | Description |
|----------|-------------|
| `Upop2000`, `Upop2025`, `Upop2050` | Population urbaine |
| `TPOP2000`, `TPOP2025`, `TPOP2050` | Population totale |
| `urban_share_XXXX` | Part urbaine (%) |
| `rural_share_XXXX` | Part rurale (%) |

### Variables de Classification

| Variable | Description |
|----------|-------------|
| `pop_class_2000`, `pop_class_2025`, `pop_class_2050` | Classe de taille de population |
| `region_num` | Région (numérique) |
| `country_num` | Pays (numérique) |

### Variables de Dynamique

| Variable | Description |
|----------|-------------|
| `urban_change_*` | Changement absolu de la part urbaine |
| `urban_growth_pct_*` | Croissance en pourcentage |
| `acceleration` | Accélération/décélération de l'urbanisation |

---

## 📐 Méthodologie

### Calcul de la Part Urbaine
```
Part Urbaine (%) = (Population Urbaine / Population Totale) × 100
```

### Calcul du Changement Absolu
```
Changement = Part_Urbaine_T2 - Part_Urbaine_T1
```

### Calcul du Taux de Croissance
```
Taux (%) = ((Part_T2 - Part_T1) / Part_T1) × 100
```

### Classification par Taille
Les agglomérations sont classées selon leur population :
- Variables binaires (`CPopulation_XXXX_*`) indiquant l'appartenance à chaque classe
- Labels standardisés pour une visualisation cohérente

### Indicateurs de Disparité
- **Plage** : Différence entre max et min
- **Coefficient de Variation** : (Écart-type / Moyenne) × 100

---

## 📝 Notes Importantes

1. **Noms de Variables** : Stata peut renommer automatiquement les variables avec espaces/caractères spéciaux. Le script gère plusieurs patterns possibles avec `capture`.

2. **Données Manquantes** : Le script utilise `if` conditions pour gérer les valeurs manquantes dans les calculs de croissance.

3. **Régions** : Les régions sont celles définies par l'Union Africaine (AU_Regions).

4. **Reproductibilité** : Le script nettoie l'environnement (`clear all`) et ferme les logs existants au démarrage.

---

## 👥 Contribution

Les contributions sont les bienvenues ! Veuillez consulter le fichier [CONTRIBUTING.md](CONTRIBUTING.md) pour plus de détails sur comment contribuer au projet.

---

## 📄 Licence

Ce projet est disponible sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

## 📧 Contact

Pour toute question concernant ce projet, veuillez ouvrir une issue sur GitHub.

---

*Dernière mise à jour : Janvier 2026*