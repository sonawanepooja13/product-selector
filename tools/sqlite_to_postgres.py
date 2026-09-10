#!/usr/bin/env python3
"""
Simple SQLite -> PostgreSQL migration script using SQLAlchemy reflection.
Usage:
  Set environment variable DATABASE_URL to target Postgres URL (e.g. postgresql://user:pass@host:5432/db)
  python tools/sqlite_to_postgres.py path/to/source.db [another.db ...]

This script reflects each source SQLite file's schema and copies tables/data into the target PostgreSQL database.
It tries to preserve column names and basic types; complex constraints or custom types may need manual migration.
"""

import os
import sys
from sqlalchemy import create_engine, MetaData, Table, select
from sqlalchemy.exc import SQLAlchemyError


def migrate_sqlite_to_postgres(sqlite_paths, target_url):
    if not target_url:
        raise RuntimeError('DATABASE_URL environment variable is required and must point to the target PostgreSQL database')

    target_engine = create_engine(target_url)

    for sqlite_path in sqlite_paths:
        if not os.path.exists(sqlite_path):
            print(f"Source SQLite file not found: {sqlite_path}")
            continue

        src_url = f"sqlite:///{os.path.abspath(sqlite_path)}"
        print(f"Migrating from {src_url} -> {target_url}")
        src_engine = create_engine(src_url)

        src_meta = MetaData()
        src_meta.reflect(bind=src_engine)

        dst_meta = MetaData()

        # Copy table schemas to destination metadata
        tables = []
        for tbl in src_meta.sorted_tables:
            if tbl.name.startswith('sqlite_'):
                continue
            try:
                new_tbl = Table(tbl.name, dst_meta)
                for col in tbl.columns:
                    # Rebind column copies into new table by using the column's copy() if available
                    try:
                        new_col = col.copy()
                    except Exception:
                        # Fallback: construct a new Column with same name and type
                        from sqlalchemy import Column
                        new_col = Column(col.name, col.type, primary_key=col.primary_key)
                    new_tbl.append_column(new_col)
                tables.append(tbl.name)
            except Exception as e:
                print(f"Error preparing table {tbl.name}: {e}")

        # Create tables in postgres (if not existing)
        try:
            dst_meta.create_all(bind=target_engine)
        except SQLAlchemyError as e:
            print(f"Error creating tables in target DB: {e}")

        # Copy data
        with src_engine.connect() as src_conn, target_engine.connect() as dst_conn:
            for tbl_name in tables:
                src_table = src_meta.tables.get(tbl_name)
                dst_table = dst_meta.tables.get(tbl_name)
                if src_table is None or dst_table is None:
                    continue
                try:
                    rows = src_conn.execute(select(src_table)).fetchall()
                    if not rows:
                        print(f"Skipping empty table {tbl_name}")
                        continue
                    # Convert rows to list of dicts
                    data = [dict(r) for r in rows]
                    # Insert in chunks
                    chunk = 500
                    for i in range(0, len(data), chunk):
                        batch = data[i:i+chunk]
                        dst_conn.execute(dst_table.insert(), batch)
                    print(f"Migrated {len(data)} rows into {tbl_name}")
                except SQLAlchemyError as e:
                    print(f"Failed to migrate table {tbl_name}: {e}")

    print("Migration complete.")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python tools/sqlite_to_postgres.py path/to/source.db [another.db ...]')
        sys.exit(1)

    sqlite_files = sys.argv[1:]
    db_url = os.environ.get('DATABASE_URL')
    try:
        migrate_sqlite_to_postgres(sqlite_files, db_url)
    except Exception as e:
        print(f'Error: {e}')
        sys.exit(2)
