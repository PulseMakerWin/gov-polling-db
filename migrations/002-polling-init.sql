CREATE SCHEMA polling;

CREATE TABLE polling.poll_created_event (
  id              serial primary key,
  creator         character varying(66) not null,
  poll_id         integer not null,
  block_created   integer, /* TODO update to not null once we update polling contract to include this*/
  start_block     integer not null,
  end_block       integer not null,
  multi_hash      character varying not null,
  
  log_index  integer not null,
  tx_id      integer not null REFERENCES vulcan2x.transaction(id) ON DELETE CASCADE,
  block_id   integer not null REFERENCES vulcan2x.block(id) ON DELETE CASCADE,
  unique (log_index, tx_id)
);

CREATE TABLE polling.poll_withdrawn_event (
  id              serial primary key,
  creator         character varying(66) not null,
  poll_id         integer not null,
  block_withdrawn integer, /* TODO update to not null once we update polling contract to include this*/
  
  log_index  integer not null,
  tx_id      integer not null REFERENCES vulcan2x.transaction(id) ON DELETE CASCADE,
  block_id   integer not null REFERENCES vulcan2x.block(id) ON DELETE CASCADE,
  unique (log_index, tx_id)
);

CREATE TABLE polling.voted_event (
  id              serial primary key,
  voter           character varying(66) not null,
  poll_id         integer not null,
  option_id       integer not null,
  
  log_index  integer not null,
  tx_id      integer not null REFERENCES vulcan2x.transaction(id) ON DELETE CASCADE,
  block_id   integer not null REFERENCES vulcan2x.block(id) ON DELETE CASCADE,
  unique (log_index, tx_id)
);
