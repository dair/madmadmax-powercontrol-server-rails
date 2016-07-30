CREATE TABLE public.chat_log(
    id serial  not null CONSTRAINT chat_log__pk PRIMARY KEY,
    dt timestamp NOT NULL default now(),
    message text NOT NULL
);
