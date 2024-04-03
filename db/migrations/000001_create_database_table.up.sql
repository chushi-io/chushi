--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Debian 14.2-1.pgdg110+1)
-- Dumped by pg_dump version 14.2 (Debian 14.2-1.pgdg110+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agents (
                               id uuid DEFAULT gen_random_uuid() NOT NULL,
                               created_at timestamp with time zone,
                               updated_at timestamp with time zone,
                               deleted_at timestamp with time zone,
                               organization_id uuid,
                               status text,
                               oauth_client_id text,
                               name text
);


ALTER TABLE public.agents OWNER TO postgres;

--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_clients (
                                      id text NOT NULL,
                                      secret character varying(512),
                                      domain character varying(512),
                                      data text,
                                      created_at timestamp with time zone,
                                      updated_at timestamp with time zone,
                                      deleted_at timestamp with time zone
);


ALTER TABLE public.oauth_clients OWNER TO postgres;

--
-- Name: oauth_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_tokens (
                                     id bigint NOT NULL,
                                     created_at timestamp with time zone,
                                     updated_at timestamp with time zone,
                                     deleted_at timestamp with time zone,
                                     expires_at timestamp with time zone,
                                     code character varying(512),
                                     access character varying(512),
                                     refresh character varying(512),
                                     data text
);


ALTER TABLE public.oauth_tokens OWNER TO postgres;

--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oauth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_tokens_id_seq OWNER TO postgres;

--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oauth_tokens_id_seq OWNED BY public.oauth_tokens.id;


--
-- Name: organization_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_users (
                                           user_id uuid DEFAULT gen_random_uuid() NOT NULL,
                                           organization_id uuid DEFAULT gen_random_uuid() NOT NULL,
                                           role text
);


ALTER TABLE public.organization_users OWNER TO postgres;

--
-- Name: organization_variable_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_variable_sets (
                                                   organization_id text NOT NULL,
                                                   variable_set_id text NOT NULL,
                                                   created_at timestamp with time zone,
                                                   updated_at timestamp with time zone,
                                                   deleted_at timestamp with time zone
);


ALTER TABLE public.organization_variable_sets OWNER TO postgres;

--
-- Name: organization_variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_variables (
                                               organization_id text NOT NULL,
                                               variable_id text NOT NULL
);


ALTER TABLE public.organization_variables OWNER TO postgres;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
                                      id uuid DEFAULT gen_random_uuid() NOT NULL,
                                      created_at timestamp with time zone,
                                      updated_at timestamp with time zone,
                                      deleted_at timestamp with time zone,
                                      name text,
                                      allow_auto_create_workspace boolean,
                                      type text,
                                      default_agent_id text
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.runs (
                             id uuid DEFAULT gen_random_uuid() NOT NULL,
                             created_at timestamp with time zone,
                             updated_at timestamp with time zone,
                             deleted_at timestamp with time zone,
                             status text,
                             workspace_id uuid,
                             add bigint,
                             change bigint,
                             destroy bigint,
                             managed_resources bigint,
                             agent_id uuid,
                             completed_at timestamp with time zone,
                             operation text,
                             source_run_id text
);


ALTER TABLE public.runs OWNER TO postgres;

--
-- Name: user_languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_languages (
                                       organization_id uuid DEFAULT gen_random_uuid() NOT NULL,
                                       user_id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.user_languages OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
                              id uuid DEFAULT gen_random_uuid() NOT NULL,
                              created_at timestamp with time zone,
                              updated_at timestamp with time zone,
                              deleted_at timestamp with time zone,
                              email text,
                              password text,
                              active boolean,
                              confirm_selector text,
                              confirm_verifier text,
                              confirmed boolean,
                              attempt_count bigint,
                              last_attempt timestamp with time zone,
                              locked timestamp with time zone,
                              recover_selector text,
                              recover_verifier text,
                              recover_token_expiry timestamp with time zone,
                              oauth2_uid text,
                              oauth2_provider text,
                              oauth2_access_token text,
                              oauth2_refresh_token text,
                              o_auth2_expiry timestamp with time zone,
                              totp_secret_key text,
                              sms_phone_number text,
                              sms_seed_phone_number text,
                              recovery_codes text,
                              oauth2_expiry timestamp with time zone,
                              recove_verifier text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: variable_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variable_sets (
                                      id uuid DEFAULT gen_random_uuid() NOT NULL,
                                      created_at timestamp with time zone,
                                      updated_at timestamp with time zone,
                                      deleted_at timestamp with time zone,
                                      organization_id text,
                                      name text,
                                      description text,
                                      auto_attach boolean,
                                      priority integer
);


ALTER TABLE public.variable_sets OWNER TO postgres;

--
-- Name: variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variables (
                                  id uuid DEFAULT gen_random_uuid() NOT NULL,
                                  created_at timestamp with time zone,
                                  updated_at timestamp with time zone,
                                  deleted_at timestamp with time zone,
                                  type text,
                                  workspace_id uuid,
                                  name text,
                                  value text,
                                  description text,
                                  sensitive boolean,
                                  variable_set_id uuid,
                                  organization_id text
);


ALTER TABLE public.variables OWNER TO postgres;

--
-- Name: vcs_connections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vcs_connections (
                                        id uuid DEFAULT gen_random_uuid() NOT NULL,
                                        created_at timestamp with time zone,
                                        updated_at timestamp with time zone,
                                        deleted_at timestamp with time zone,
                                        name text,
                                        provider text,
                                        github_type text,
                                        github_personal_access_token text,
                                        github_application_id text,
                                        github_application_secret text,
                                        github_oauth_application_id text,
                                        github_oauth_application_secret text,
                                        organization_id uuid,
                                        webhook_id text,
                                        webhook_secret text
);


ALTER TABLE public.vcs_connections OWNER TO postgres;

--
-- Name: workspace_variable_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspace_variable_sets (
                                                workspace_id text NOT NULL,
                                                variable_set_id text NOT NULL,
                                                created_at timestamp with time zone,
                                                updated_at timestamp with time zone,
                                                deleted_at timestamp with time zone
);


ALTER TABLE public.workspace_variable_sets OWNER TO postgres;

--
-- Name: workspace_variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspace_variables (
                                            workspace_id text NOT NULL,
                                            variable_id text NOT NULL,
                                            created_at timestamp with time zone,
                                            updated_at timestamp with time zone,
                                            deleted_at timestamp with time zone
);


ALTER TABLE public.workspace_variables OWNER TO postgres;

--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspaces (
                                   id uuid DEFAULT gen_random_uuid() NOT NULL,
                                   created_at timestamp with time zone,
                                   updated_at timestamp with time zone,
                                   deleted_at timestamp with time zone,
                                   name text,
                                   allow_destroy boolean,
                                   auto_apply boolean,
                                   auto_destroy_at timestamp with time zone,
                                   execution_mode text,
                                   vcs_source text,
                                   vcs_branch text,
                                   vcs_patterns text,
                                   vcs_prefixes text,
                                   vcs_working_directory text,
                                   version text,
                                   locked boolean,
                                   lock_by text,
                                   lock_at text,
                                   lock_id text,
                                   organization_id uuid,
                                   agent_id uuid,
                                   drift_detection_enabled boolean,
                                   drift_detection_schedule text,
                                   vcs_connection_id text
);


ALTER TABLE public.workspaces OWNER TO postgres;

--
-- Name: oauth_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_tokens_id_seq'::regclass);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: organizations idx_organizations_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT idx_organizations_name UNIQUE (name);


--
-- Name: users idx_users_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT idx_users_email UNIQUE (email);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_tokens oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_tokens
    ADD CONSTRAINT oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: organization_users organization_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_pkey PRIMARY KEY (user_id, organization_id);


--
-- Name: organization_variable_sets organization_variable_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_variable_sets
    ADD CONSTRAINT organization_variable_sets_pkey PRIMARY KEY (organization_id, variable_set_id);


--
-- Name: organization_variables organization_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_variables
    ADD CONSTRAINT organization_variables_pkey PRIMARY KEY (organization_id, variable_id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: runs runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: user_languages user_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT user_languages_pkey PRIMARY KEY (organization_id, user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variable_sets variable_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variable_sets
    ADD CONSTRAINT variable_sets_pkey PRIMARY KEY (id);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: vcs_connections vcs_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vcs_connections
    ADD CONSTRAINT vcs_connections_pkey PRIMARY KEY (id);


--
-- Name: workspace_variable_sets workspace_variable_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_variable_sets
    ADD CONSTRAINT workspace_variable_sets_pkey PRIMARY KEY (workspace_id, variable_set_id);


--
-- Name: workspace_variables workspace_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_variables
    ADD CONSTRAINT workspace_variables_pkey PRIMARY KEY (workspace_id, variable_id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: idx_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_email ON public.users USING btree (email);


--
-- Name: idx_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_name ON public.organizations USING btree (name);


--
-- Name: idx_oauth_clients_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_oauth_clients_deleted_at ON public.oauth_clients USING btree (deleted_at);


--
-- Name: idx_oauth_tokens_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_oauth_tokens_deleted_at ON public.oauth_tokens USING btree (deleted_at);


--
-- Name: agents fk_agents_oauth_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT fk_agents_oauth_client FOREIGN KEY (oauth_client_id) REFERENCES public.oauth_clients(id);


--
-- Name: agents fk_agents_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT fk_agents_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_users fk_organization_users_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT fk_organization_users_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_users fk_organization_users_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT fk_organization_users_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: runs fk_runs_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_runs_agent FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- Name: runs fk_runs_workspace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_runs_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: user_languages fk_user_languages_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT fk_user_languages_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: user_languages fk_user_languages_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_languages
    ADD CONSTRAINT fk_user_languages_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: variables fk_variable_sets_variables; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_variable_sets_variables FOREIGN KEY (variable_set_id) REFERENCES public.variable_sets(id);


--
-- Name: variables fk_variables_workspace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_variables_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: vcs_connections fk_vcs_connections_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vcs_connections
    ADD CONSTRAINT fk_vcs_connections_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: workspaces fk_workspaces_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT fk_workspaces_agent FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- Name: workspaces fk_workspaces_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT fk_workspaces_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- PostgreSQL database dump complete
--

