"""Explore le catalogue Odissé (API Opendatasoft v2.1).

Usage :
    python ingestion/explore_catalog.py               -> recherche par mots-clés
    python ingestion/explore_catalog.py <dataset_id>  -> colonnes + modalités + aperçu
"""
import sys

import requests

BASE_URL = "https://odisse.santepubliquefrance.fr/api/explore/v2.1"
KEYWORDS = ["suicide", "anxieux", "bien-être", "alcool", "sommeil", "activité physique", "dépression", "dépressif"]
TIMEOUT = 30


def get(path: str, **params) -> dict:
    r = requests.get(f"{BASE_URL}{path}", params=params, timeout=TIMEOUT)
    r.raise_for_status()
    return r.json()


def search(keyword: str) -> None:
    # Une chaîne entre guillemets dans "where" = recherche plein texte
    data = get("/catalog/datasets", where=f'"{keyword}"', limit=100)
    print(f"\n=== {keyword} ({data['total_count']} résultats)")
    for ds in data["results"]:
        m = ds["metas"]["default"]
        print(f"  {ds['dataset_id']:<55} {m.get('records_count', '?'):>7}  {m.get('title')}")


def describe(dataset_id: str) -> None:
    ds = get(f"/catalog/datasets/{dataset_id}")
    m = ds["metas"]["default"]
    print(f"\n{m.get('title')}\nMis à jour : {m.get('modified')} | {m.get('records_count')} lignes\n")

    print("Colonnes :")
    for f in ds["fields"]:
        print(f"  {f['name']:<35} {f['type']:<10} {f.get('label')}")

    # Modalités des colonnes texte (sexe, âge, région, indicateur...)
    print("\nModalités (30 max par colonne) :")
    for f in ds["fields"]:
        if f["type"] != "text":
            continue
        res = get(f"/catalog/datasets/{dataset_id}/records",
                  select="count(*) as n", group_by=f["name"], limit=30)
        values = [f"{r[f['name']]} ({r['n']})" for r in res["results"]]
        print(f"  {f['name']}: {', '.join(map(str, values))}")

    print("\nAperçu :")
    for rec in get(f"/catalog/datasets/{dataset_id}/records", limit=3)["results"]:
        print(" ", rec)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        describe(sys.argv[1])
    else:
        for kw in KEYWORDS:
            search(kw)