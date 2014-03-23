-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- PostgreSQL version: 9.1
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --

-- object: public.device | type: TABLE --
CREATE TABLE public.device(
	id varchar(255) NOT NULL,
	name varchar(255) DEFAULT NULL,
	type char NOT NULL DEFAULT 'V',
	CONSTRAINT device_pk_id PRIMARY KEY (id)

);
-- ddl-end --
-- object: name_idx | type: INDEX --
CREATE INDEX name_idx ON public.device
	USING btree
	(
	  name ASC NULLS LAST
	);
-- ddl-end --


-- object: public.point | type: TABLE --
CREATE TABLE public.point(
	dt timestamp NOT NULL,
	dt_recv timestamp NOT NULL DEFAULT now(),
	latitude double precision NOT NULL,
	longitude double precision NOT NULL,
	device_id varchar(255) NOT NULL
);
-- ddl-end --
-- object: dt_idx | type: INDEX --
CREATE INDEX dt_idx ON public.point
	USING btree
	(
	  device_id ASC NULLS LAST,
	  dt ASC NULLS LAST
	);
-- ddl-end --

-- object: dt_recv_idx | type: INDEX --
CREATE INDEX dt_recv_idx ON public.point
	USING btree
	(
	  device_id ASC NULLS LAST,
	  dt_recv ASC NULLS LAST
	);
-- ddl-end --


-- object: device_fk | type: CONSTRAINT --
ALTER TABLE public.point ADD CONSTRAINT device_fk FOREIGN KEY (device_id)
REFERENCES public.device (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: public.user | type: TABLE --
CREATE TABLE public.user(
	name varchar(42) NOT NULL,
	status char NOT NULL default 'U',
	hash varchar(128) NOT NULL,
	CONSTRAINT name_pk PRIMARY KEY (name)

);
-- ddl-end --
-- object: dt_idx | type: INDEX --
CREATE INDEX dt_idx ON public.point
	USING btree
	(
	  device_id ASC NULLS LAST,
	  dt ASC NULLS LAST
	);
-- ddl-end --

-- object: dt_recv_idx | type: INDEX --
CREATE INDEX dt_recv_idx ON public.point
	USING btree
	(
	  device_id ASC NULLS LAST,
	  dt_recv ASC NULLS LAST
	);
-- ddl-end --

CREATE TABLE public.map (
    map bytea,
    latitude double precision,
    longitude double precision
);

ALTER DATABASE database_name SET bytea_output TO 'escape';
