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
-- Name: error_rate_daily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_rate_daily (
    project_id uuid NOT NULL,
    date date NOT NULL,
    success_count integer,
    error_count integer,
    error_rate double precision
);


--
-- Name: invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice (
    stripe_invoice_id text NOT NULL,
    customer_id text NOT NULL,
    subscription_id text,
    month integer NOT NULL,
    year integer NOT NULL,
    description text,
    status text NOT NULL,
    invoice_url text,
    attempt_count integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: invoice_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_item (
    id uuid NOT NULL,
    invoice_id text NOT NULL,
    amount numeric NOT NULL,
    description text,
    project_id uuid NOT NULL,
    type text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    has_updated_to_stripe boolean NOT NULL,
    error text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: plan_entitlement_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_entitlement_access (
    id uuid NOT NULL,
    plan_id uuid NOT NULL,
    entitlement_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plans (
    id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: project_entitlement_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_entitlement_access (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    entitlement_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: project_entitlement_catalog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_entitlement_catalog (
    id uuid NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    config_limit integer,
    config_is_enabled boolean,
    name text NOT NULL,
    base_cost numeric
);


--
-- Name: project_plan_changelogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_plan_changelogs (
    id uuid NOT NULL,
    plan_id uuid NOT NULL,
    project_id uuid NOT NULL,
    comment text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    name text NOT NULL,
    owner_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    active_models integer NOT NULL,
    active_commands integer NOT NULL
);


--
-- Name: requests_daily_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requests_daily_count (
    project_id uuid NOT NULL,
    date date NOT NULL,
    request_count integer NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email text NOT NULL,
    customer_id text NOT NULL,
    max_project_limit integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    zendesk_user_id integer,
    organization_id text,
    first_name text,
    last_name text
);


--
-- Name: error_rate_daily error_rate_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_rate_daily
    ADD CONSTRAINT error_rate_daily_pkey PRIMARY KEY (project_id, date);


--
-- Name: invoice_item invoice_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_item
    ADD CONSTRAINT invoice_item_pkey PRIMARY KEY (id);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (stripe_invoice_id);


--
-- Name: plan_entitlement_access plan_entitlement_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_entitlement_access
    ADD CONSTRAINT plan_entitlement_access_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: project_entitlement_access project_entitlement_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_entitlement_access
    ADD CONSTRAINT project_entitlement_access_pkey PRIMARY KEY (id);


--
-- Name: project_entitlement_catalog project_entitlement_catalog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_entitlement_catalog
    ADD CONSTRAINT project_entitlement_catalog_pkey PRIMARY KEY (id);


--
-- Name: project_plan_changelogs project_plan_changelogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_plan_changelogs
    ADD CONSTRAINT project_plan_changelogs_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: requests_daily_count requests_daily_count_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests_daily_count
    ADD CONSTRAINT requests_daily_count_pkey PRIMARY KEY (project_id, date);


--
-- Name: users users_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_customer_id_key UNIQUE (customer_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_zendesk_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_zendesk_user_id_key UNIQUE (zendesk_user_id);


--
-- Name: error_rate_daily error_rate_daily_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_rate_daily
    ADD CONSTRAINT error_rate_daily_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: invoice invoice_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(customer_id);


--
-- Name: invoice_item invoice_item_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_item
    ADD CONSTRAINT invoice_item_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoice(stripe_invoice_id);


--
-- Name: invoice_item invoice_item_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_item
    ADD CONSTRAINT invoice_item_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: plan_entitlement_access plan_entitlement_access_entitlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_entitlement_access
    ADD CONSTRAINT plan_entitlement_access_entitlement_id_fkey FOREIGN KEY (entitlement_id) REFERENCES public.project_entitlement_catalog(id);


--
-- Name: plan_entitlement_access plan_entitlement_access_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_entitlement_access
    ADD CONSTRAINT plan_entitlement_access_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: project_entitlement_access project_entitlement_access_entitlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_entitlement_access
    ADD CONSTRAINT project_entitlement_access_entitlement_id_fkey FOREIGN KEY (entitlement_id) REFERENCES public.project_entitlement_catalog(id);


--
-- Name: project_entitlement_access project_entitlement_access_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_entitlement_access
    ADD CONSTRAINT project_entitlement_access_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_plan_changelogs project_plan_changelogs_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_plan_changelogs
    ADD CONSTRAINT project_plan_changelogs_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: project_plan_changelogs project_plan_changelogs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_plan_changelogs
    ADD CONSTRAINT project_plan_changelogs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects projects_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: requests_daily_count requests_daily_count_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests_daily_count
    ADD CONSTRAINT requests_daily_count_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- PostgreSQL database dump complete
--

