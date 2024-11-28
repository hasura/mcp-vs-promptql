--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.6 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: google_vacuum_mgmt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA google_vacuum_mgmt;


--
-- Name: google_vacuum_mgmt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS google_vacuum_mgmt WITH SCHEMA google_vacuum_mgmt;


--
-- Name: EXTENSION google_vacuum_mgmt; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION google_vacuum_mgmt IS 'extension for assistive operational tooling';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: support_ticket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_ticket (
    id integer NOT NULL,
    is_public boolean NOT NULL,
    priority text,
    status text,
    subject text,
    description text,
    type text,
    assignee_id integer,
    requester_id integer,
    created_at timestamp with time zone,
    url text
);


--
-- Name: support_ticket_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_ticket_comment (
    id integer NOT NULL,
    ticket_id integer,
    body text,
    created_at timestamp with time zone,
    user_id integer
);


--
-- Name: support_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_user (
    id integer NOT NULL,
    email text,
    role text
);

--
-- Name: support_ticket_comment support_ticket_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_comment
    ADD CONSTRAINT support_ticket_comment_pkey PRIMARY KEY (id);


--
-- Name: support_ticket support_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket
    ADD CONSTRAINT support_ticket_pkey PRIMARY KEY (id);


--
-- Name: support_user support_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_user
    ADD CONSTRAINT support_user_pkey PRIMARY KEY (id);


--
-- Name: support_ticket support_ticket_assignee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket
    ADD CONSTRAINT support_ticket_assignee_id_fkey FOREIGN KEY (assignee_id) REFERENCES public.support_user(id);


--
-- Name: support_ticket_comment support_ticket_comment_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_comment
    ADD CONSTRAINT support_ticket_comment_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_ticket(id);


--
-- Name: support_ticket_comment support_ticket_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_comment
    ADD CONSTRAINT support_ticket_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.support_user(id);


--
-- Name: support_ticket support_ticket_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket
    ADD CONSTRAINT support_ticket_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.support_user(id);


--
-- PostgreSQL database dump complete
--

