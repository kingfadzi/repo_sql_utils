import yaml
import json
from sqlalchemy import create_engine, Column, String, text, inspect, MetaData
from sqlalchemy.orm import sessionmaker, declarative_base

Base = declarative_base()

def convert_value(value):
    return json.dumps(value) if isinstance(value, (list, dict)) else value

def get_connection():
    return create_engine(
        'postgresql://postgres:postgres@192.168.1.188/gitlab-usage',
        pool_pre_ping=True
    )

def drop_table_if_exists(engine, table_name):
    with engine.connect() as conn:
        conn.execute(text(f'DROP TABLE IF EXISTS {table_name} '))
        conn.commit()

def get_dynamic_class(engine):
    """Create new ORM class reflecting current table structure"""
    metadata = MetaData()
    metadata.reflect(bind=engine, only=['languages'])

    if 'languages' not in metadata.tables:
        return None

    return type(
        'Language',
        (Base,),
        {'__table__': metadata.tables['languages']}
    )

def process_file(session, engine, file_path, is_initial=False):
    with open(file_path) as f:
        data = yaml.safe_load(f)

    if is_initial:
        # Create initial table with selected columns
        columns = {
            'name': Column(String, primary_key=True),
            'type': Column(String),
            'extensions': Column(String)
        }

        DynamicTable = type(
            'LanguageInitial',
            (Base,),
            {'__tablename__': 'languages', **columns}
        )
        Base.metadata.create_all(engine)
    else:
        # Add new columns from enrichment data
        inspector = inspect(engine)
        existing_columns = {col['name'] for col in inspector.get_columns('languages')}

        for lang_data in data.values():
            for key in lang_data.keys():
                if key not in existing_columns:
                    with engine.connect() as conn:
                        conn.execute(
                            text(f'ALTER TABLE languages ADD COLUMN IF NOT EXISTS "{key}" TEXT')
                        )
                        conn.commit()

    # Get updated ORM class
    DynamicTable = get_dynamic_class(engine)
    if not DynamicTable:
        raise RuntimeError("Table 'languages' not found")

    # Insert/update data
    for lang_name, lang_data in data.items():
        row_data = {'name': lang_name}
        if is_initial:
            row_data.update({
                'type': lang_data.get('type'),
                'extensions': convert_value(lang_data.get('extensions', []))
            })
        else:
            row_data.update({k: convert_value(v) for k, v in lang_data.items()})

        session.merge(DynamicTable(**row_data))

    session.commit()

def main():
    engine = get_connection()
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        drop_table_if_exists(engine, 'languages')
        process_file(session, engine, 'languages.yaml', is_initial=True)
        process_file(session, engine, 'enrichment.yaml')
        print("Data loaded successfully!")
    except Exception as e:
        session.rollback()
        print(f"Error: {str(e)}")
    finally:
        session.close()

if __name__ == "__main__":
    main()
