# Real Estate Analytics (SQL + PostgreSQL + Metabase)

SQL-аналитика рынка недвижимости Москвы: синтетические объявления о продаже жилья
превращаются в отчётные витрины с оконными функциями и визуализируются в Metabase.

## Цель проекта

Показать полный аналитический цикл Data Engineer/аналитика: загрузка сырых данных,
чистка и типизация (STG → DDS), построение витрин на оконных функциях и агрегациях,
ад-хок запросы и дашборд. Фокус — на SQL, который превращает сырые данные в отчётные таблицы.

## Стек

- PostgreSQL 15 — хранилище (слои STG / DDS / CDM)
- Python (pandas, psycopg2) — загрузка CSV через COPY
- Metabase — BI-дашборд
- Docker Compose — воспроизводимая среда

## Данные

Датасет синтетический, генерируется скриптом `src/generate_sample.py`:
объявления о продаже квартир по округам Москвы с зависимостью цены за м²
от района, типа дома и количества комнат. Для быстрой проверки в репозитории
лежит `data/sample.csv`. Внешние источники не используются.

## Витрины (CDM)

| Витрина | Что показывает | Ключевые приёмы |
|---|---|---|
| `cdm.rooms_metrics` | медиана и перцентили цены за м² по комнатам | PERCENTILE_CONT, GROUP BY |
| `cdm.price_segments` | разбиение рынка на ценовые кварталы | NTILE(4), оконная доля рынка |
| `cdm.building_type_metrics` | панель vs монолит vs кирпич: на сколько % дороже рынка | оконное среднее, CROSS JOIN |
| `cdm.district_share` | доля рынка по округам и ранжирование | RANK, SUM() OVER |
| `cdm.price_extremes` | самые дешёвые и дорогие предложения по комнатам | ROW_NUMBER, UNION ALL |

## Как запустить

1. Заполните подключения: значения `ВПИШИТЕ_*` в `configs/config.yaml` и `docker/docker-compose.yml`.
2. `docker compose -f docker/docker-compose.yml up -d`
3. Выполните SQL из `sql/` по порядку: 01 → 02.
4. Установите зависимости и подготовьте данные:
   ```bash
   pip install -r requirements.txt
   python src/generate_sample.py 50000
   python src/load_data.py data/sample_large.csv
