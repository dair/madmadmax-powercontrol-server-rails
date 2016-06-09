-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- PostgreSQL version: 9.1
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --

-- object: public.device | type: TABLE --
CREATE TABLE public.device(
    id varchar(255) NOT NULL,
    hw_id varchar(255) NOT NULL,
    name varchar(255) NOT NULL,
    description varchar(255) DEFAULT NULL,
    CONSTRAINT device_pk_id PRIMARY KEY (id)
);
-- ddl-end --
-- object: name_idx | type: INDEX --
CREATE INDEX dev_id_idx ON public.device
    USING btree
    (
      id ASC NULLS LAST
    );

CREATE INDEX dev_hw_id_idx ON public.device
    USING btree
    (
      hw_id ASC NULLS LAST
    );

CREATE INDEX name_idx ON public.device
    USING btree
    (
      name ASC NULLS LAST
    );

-- ddl-end --


-- object: public.point | type: TABLE --
CREATE TABLE public.point(
    device_id varchar(255) NOT NULL,
    dt timestamp NOT NULL,
    dt_recv timestamp NOT NULL DEFAULT now(),
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    speed double precision NOT NULL,
    distance double precision NOT NULL
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

CREATE table public.device_ping (
    device_id varchar(255) NOT NULL,
    dt timestamp NOT NULL default now(),
    dt_device timestamp NOT NULL,
    msg_type char(1) NOT NULL,
    message varchar(255)
);

CREATE INDEX device_ping_dt_idx ON public.device_ping
    USING btree
    (
        device_id ASC NULLS LAST,
        dt ASC NULLS LAST
    );

CREATE INDEX device_ping__dt_device__idx ON public.device_ping
    USING btree
    (
        device_id ASC NULLS LAST,
        dt_device ASC NULLS LAST
    );

ALTER TABLE public.device_ping ADD CONSTRAINT device_fk FOREIGN KEY (device_id)
REFERENCES public.device (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;

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

-- parameter

CREATE TABLE public.parameter (
    id varchar(20) not null,
    name varchar(255) not null,
    CONSTRAINT id_parameter_pk PRIMARY KEY (id)
);

-- command: id, date
CREATE TABLE public.command (
    id serial not null CONSTRAINT command_pk PRIMARY KEY,
    device_id varchar(255) REFERENCES public.device ON DELETE CASCADE,
    dt timestamp NOT NULL default now(),
    user_name varchar(42) not null REFERENCES public.user MATCH FULL
);
-- command: numeric id, name, value

CREATE TABLE public.command_data (
    id serial not null REFERENCES public.command MATCH FULL,
    param_id varchar(20) not null REFERENCES public.parameter MATCH FULL,
    value varchar(20) not null,

    CONSTRAINT num_param_id_command_pk PRIMARY KEY (id, param_id)
);

--ALTER TABLE public.command ADD CONSTRAINT command_parameter_fk FOREIGN KEY (param_id)
--    REFERENCES public.parameter (id) MATCH FULL
--    ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

CREATE INDEX command_id_idx ON public.command_data
    USING btree
    (
        id ASC NULLS FIRST
    );

------------------------------ FUEL CODES

CREATE TABLE public.fuel_code (
    code varchar(20) not null constraint fuel_code_pk primary key,
    amount integer not null default 0,
    dev_id varchar(255) default null REFERENCES public.device ON DELETE RESTRICT,
    dt timestamp default null
);


CREATE TABLE public.device_stat (
    dev_id varchar(255) not null REFERENCES public.device ON DELETE CASCADE,
    dt timestamp not null,
    key varchar(20) not null,
    value varchar(255) not null,
    
    CONSTRAINT device_stat__pk PRIMARY KEY (dev_id, dt, key)
);

CREATE INDEX device_stat__dt__idx on device_stat using btree (dt asc);
CREATE INDEX device_stat__key__idx on device_stat using btree (key asc);
CREATE INDEX device_stat__dev_id__idx on device_stat using btree (dev_id asc);

CREATE TABLE device_info (
    dev_id varchar(255) not null REFERENCES public.device ON DELETE CASCADE,
    key varchar(255) not null,
    value varchar(255) not null,
    dt timestamp not null default now(),

    CONSTRAINT device_info__pk PRIMARY KEY (dev_id, key)
);
CREATE INDEX device_info__dev_id__idx on device_info using btree (dev_id asc);
CREATE INDEX device_info__key__idx on device_info using btree (key asc);

create rule log_device_info as on INSERT to device_info
    where exists (select 1 from device_info d where d.dev_id = NEW.dev_id and d.key = NEW.key)
    do instead update device_info set value = new.value, dt = new.dt where dev_id = new.dev_id and key = new.key;


ALTER DATABASE __DATABASE_NAME__ SET bytea_output TO 'escape';

