DROP SCHEMA IF EXISTS results CASCADE;
CREATE SCHEMA results;

-- model table containing each of the models run.
CREATE TABLE results.models (
  model_id          SERIAL PRIMARY KEY,
  run_time          TIMESTAMP default current_timestamp,
  model_type        TEXT,
  model_parameters  JSONB,
  features          TEXT[],
  year_train        VARCHAR(4),
  grid_size         TEXT,
  intersect_percent INT, 
  model_comment     TEXT
);

-- predictions table
CREATE TABLE results.predictions (
  model_id      INT REFERENCES results.models (model_id),
  year_test     VARCHAR(4),
  cell_id       INT,
  score         REAL,
  label         BOOL
);

-- feature importance table
CREATE TABLE results.feature_importances (
  model_id             INT REFERENCES results.models (model_id),
  feature              TEXT,
  feature_importance   REAL,
  rank_abs             INT
);
