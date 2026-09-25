"""Télécharge les jeux de données Odissé listés dans ingestion/datasets.yml vers data/raw/."""
from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path

import duckdb
import requests
import yaml

BASE_URL = "https://odisse.santepubliquefrance.fr/api/explore/v2.1"
ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
CONFIG = Path(__file__).with_name("datasets.yml")
TIMEOUT = 120


def load_config() -> list[dict]:
    with CONFIG.open(encoding="utf-8") as f:
        return yaml.safe_load(f)["datasets"]


def fetch_metadata(session: requests.Session, dataset_id: str) -> dict:
    r = session.get(f"{BASE_URL}/catalog/datasets/{dataset_id}", timeout=TIMEOUT)
    r.raise_for_status()
    return r.json()


def download_parquet(session: requests.Session, dataset_id: str, dest: Path) -> None:
    tmp = dest.with_name(dest.name + ".part")
    url = f"{BASE_URL}/catalog/datasets/{dataset_id}/exports/parquet"
    with session.get(url, stream=True, timeout=TIMEOUT) as r:
        r.raise_for_status()
        with tmp.open("wb") as f:
            for chunk in r.iter_content(chunk_size=1 << 20):
                f.write(chunk)
    tmp.replace(dest)  # remplacement atomique


def count_rows(path: Path) -> int:
    return duckdb.sql(f"select count(*) from read_parquet('{path.as_posix()}')").fetchone()[0]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", nargs="*", help="identifiants à télécharger (défaut : tous)")
    args = parser.parse_args()

    datasets = load_config()
    if args.only:
        datasets = [d for d in datasets if d["id"] in args.only]

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    manifest_path = RAW_DIR / "_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {}

    errors = []
    with requests.Session() as session:
        session.headers["User-Agent"] = "odisse-pipeline (projet personnel)"
        for d in datasets:
            ds_id = d["id"]
            try:
                meta = fetch_metadata(session, ds_id)
                dest = RAW_DIR / f"{ds_id}.parquet"
                download_parquet(session, ds_id, dest)
                (RAW_DIR / f"{ds_id}.metadata.json").write_text(
                    json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8"
                )
                n = count_rows(dest)
                manifest[ds_id] = {
                    "theme": d.get("theme"),
                    "file": dest.name,
                    "rows": n,
                    "source_modified": meta["metas"]["default"].get("modified"),
                    "downloaded_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                }
                print(f"OK   {ds_id:<55} {n:>7} lignes")
            except Exception as e:  # on continue avec les autres jeux
                errors.append(ds_id)
                print(f"ERR  {ds_id:<55} {e}")

    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    if errors:
        raise SystemExit(f"{len(errors)} échec(s) : {', '.join(errors)}")


if __name__ == "__main__":
    main()