def bootstrap():
    last_error = None

    for attempt in range(40):
        try:
            print(f"[BOOTSTRAP] Inventory DB attempt {attempt + 1}/40")

            with conn() as c:
                c.execute("""
                    CREATE TABLE IF NOT EXISTS inventory(
                        store_id text,
                        sku text,
                        item_name text,
                        unit text,
                        stock numeric,
                        forecast_4h numeric,
                        PRIMARY KEY(store_id, sku)
                    )
                """)

                n = c.execute(
                    "SELECT count(*) FROM inventory"
                ).fetchone()[0]

                if n == 0:
                    c.executemany(
                        "INSERT INTO inventory VALUES (%s,%s,%s,%s,%s,%s)",
                        [
                            ('STORE-042','CHK','Pollo','kg',38,61),
                            ('STORE-042','POT','Papas','kg',74,52),
                            ('STORE-042','OIL','Aceite','L',21,30),
                            ('STORE-042','PKG','Empaques','u',425,310)
                        ]
                    )

                c.commit()

            print("[BOOTSTRAP] Inventory database READY")
            return

        except Exception as e:
            last_error = e
            print(f"[BOOTSTRAP] attempt {attempt + 1} failed: {e}")
            time.sleep(1)

    raise RuntimeError(
        f"Inventory database bootstrap failed: {last_error}"
    )
