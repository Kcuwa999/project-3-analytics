import csv
import random
import sys
from pathlib import Path

DISTRICTS = {
    "Центральный АО": 1.55,
    "Западный АО": 1.25,
    "Северо-Западный АО": 1.10,
    "Северный АО": 1.05,
    "Северо-Восточный АО": 0.95,
    "Восточный АО": 0.90,
    "Юго-Восточный АО": 0.85,
    "Южный АО": 0.88,
    "Юго-Западный АО": 1.10,
}
BUILDING_TYPES = {2: 1.0, 3: 1.08, 4: 1.12}
ROOMS_AREA = {-1: (24, 34), 1: (32, 46), 2: (50, 70), 3: (72, 100)}
BASE_PRICE_PER_SQM = 230000


def make_row(rng):
    district = rng.choice(list(DISTRICTS))
    building = rng.choices(list(BUILDING_TYPES), weights=[55, 25, 20])[0]
    rooms = rng.choices([-1, 1, 2, 3], weights=[10, 35, 35, 20])[0]
    area = round(rng.uniform(*ROOMS_AREA[rooms]), 1)
    price_sqm = BASE_PRICE_PER_SQM * DISTRICTS[district] * BUILDING_TYPES[building]
    price_sqm *= rng.uniform(0.88, 1.12)
    price = round(price_sqm * area / 1000) * 1000
    lat = round(rng.uniform(55.60, 55.90), 4)
    lon = round(rng.uniform(37.25, 37.90), 4)
    object_type = 2 if rng.random() < 0.2 else 0
    return [object_type, "Москва", building, rooms, area, price, lat, lon, district]


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 50000
    out = Path("data/sample_large.csv")
    rng = random.Random(42)
    with out.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["object_type", "region", "building_type", "rooms",
                         "area", "price", "latitude", "longitude", "district"])
        for _ in range(n):
            writer.writerow(make_row(rng))
    print(f"Created {out}: {n} rows")


if __name__ == "__main__":
    main()
