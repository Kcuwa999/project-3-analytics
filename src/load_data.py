import csv
import io
import sys

import pandas as pd
import psycopg2
import yaml


def load_yaml(path):
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def map_columns(df, candidates, required):
    found = {}
    for target, options in candidates.items():
        for option in options:
            if option in df.columns:
                found[target] = option
                break
    missing = [c for c in required if c not in found]
    if missing:
        raise ValueError(f"Missing columns: {missing}, got: {list(df.columns)}")
    return df.rename(columns={v: k for k, v in found.items()})


def main():
    cfg = load_yaml("configs/config.yaml")
    mapping = load_yaml("configs/mapping.yaml")

    csv_path = sys.argv[1] if len(sys.argv) > 1 else "data/sample.csv"
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else cfg["load"]["default_limit"]

    df = pd.read_csv(csv_path, low_memory=False)
    if limit and len(df) > limit:
        df = df.head(limit)
    df = map_columns(df, mapping["mapping"], mapping["required"])
    df = df.reindex(columns=[c for c in mapping["mapping"] if c in df.columns], fill_value=None)
    df = df.where(pd.notnull(df), None)

    db = cfg["postgres"]
    conn = psycopg2.connect(
        host=db["host"],
        port=db["port"],
        dbname=db["dbname"],
        user=db["user"],
        password=db["password"],
    )
    try:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE stg.realty_raw")
            buf = io.StringIO()
            writer = csv.writer(buf, quoting=csv.QUOTE_MINIMAL)
            for row in df.itertuples(index=False, name=None):
                writer.writerow(["" if v is None else v for v in row])
            buf.seek(0)
            columns = [c for c in mapping["mapping"] if c in df.columns]
            cur.copy_expert(
                f"COPY stg.realty_raw ({', '.join(columns)}) FROM STDIN WITH CSV",
                buf,
            )
        conn.commit()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
