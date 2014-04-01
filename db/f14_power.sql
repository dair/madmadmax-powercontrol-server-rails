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
    description varchar(255) DEFAULT NULL,
    type char DEFAULT NULL,
    CONSTRAINT device_pk_id PRIMARY KEY (id)
);
-- ddl-end --
-- object: name_idx | type: INDEX --
CREATE INDEX dev_id_idx ON public.device
    USING btree
    (
      id ASC NULLS LAST
    );

CREATE INDEX name_idx ON public.device
    USING btree
    (
      name ASC NULLS LAST
    );

CREATE INDEX devtype_idx ON public.device
    USING btree
    (
        type ASC NULLS FIRST
    );

-- ddl-end --


-- object: public.point | type: TABLE --
CREATE TABLE public.point(
    device_id varchar(255) NOT NULL,
    dt timestamp NOT NULL,
    dt_recv timestamp NOT NULL DEFAULT now(),
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    speed double precision NOT NULL
);
-- ddl-end --
-- object: dt_idx | type: INDEX --
CREATE INDEX point_dt_idx ON public.point
    USING btree
    (
        device_id ASC NULLS LAST,
        dt ASC NULLS LAST
    );
-- ddl-end --

-- object: dt_recv_idx | type: INDEX --
CREATE INDEX point_dt_recv_idx ON public.point
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

-- object: dt_recv_idx | type: INDEX --
CREATE INDEX user_status_idx ON public.user
    USING btree
    (
        status ASC NULLS LAST
    );
-- ddl-end --

CREATE TABLE public.map (
    map bytea,
    latitude double precision,
    longitude double precision
);

-- parameters
CREATE TABLE public.parameters (
    name varchar(10) not null,
    device_id varchar(255),
    value varchar(20) not null,

    CONSTRAINT name_device_pk PRIMARY KEY (name, device_id)
);

ALTER TABLE public.parameters ADD CONSTRAINT device_params_fk FOREIGN KEY (device_id)
REFERENCES public.device (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

CREATE INDEX parameters_idx ON public.parameters
    USING btree
    (
        device_id ASC NULLS FIRST,
        name ASC NULLS FIRST
    );

ALTER DATABASE __DATABASE_NAME__ SET bytea_output TO 'escape';

