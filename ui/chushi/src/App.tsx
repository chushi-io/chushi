import './App.css'
import '@mantine/core/styles.css';
import {MantineProvider} from '@mantine/core';
import {AuthProvider, hasAuthParams, useAuth} from "react-oidc-context";
import {User, WebStorageStateStore} from "oidc-client-ts";
import {useEffect, useRef, useState} from "react";
// @ts-ignore
import Router from "./Router.tsx";
import {apiClient} from "./Client.tsx";

import { lazy } from 'react';
const AppRouter = lazy(() => import('./Router.tsx'));
// let oidcConfigLoaded = false
let oidcConfig = {
  authority: "https://caring-foxhound-whole.ngrok-free.app",
  client_id: "c-grvyKTI0gxf1SvvVoHs7hKGTmYoKDygEI7yiljdSM",
  redirect_uri: location.protocol + '//' + location.host + "/app",
  userStore: new WebStorageStateStore({ store: window.localStorage }),
}


export default function App() {
  return <MantineProvider>
    <AuthProvider {...oidcConfig} onSigninCallback={(_user: User | void) => {
      window.history.replaceState({}, document.title, window.location.pathname)
    }}>
      <Main />
    </AuthProvider>
  </MantineProvider>
}

const Main = () => {
    const auth = useAuth();
  const accessTokenRef = useRef("");

    const [hasTriedSignin, setHasTriedSignin] = useState(false);

    // automatically sign-in
    useEffect(() => {
      if (!hasAuthParams() &&
        !auth.isAuthenticated && !auth.activeNavigator && !auth.isLoading &&
        !hasTriedSignin
      ) {
        auth.signinRedirect();
        setHasTriedSignin(true);
      }
    }, [auth, hasTriedSignin]);

    useEffect(() => {
      const requestInterceptor = apiClient.interceptors.request.use(
        (config) => {
          config.headers["Authorization"] = `Bearer ${accessTokenRef.current}`;
          return config;
        },
      );

      const responseInterceptor = apiClient.interceptors.response.use(
        (response) => {
          return response;
        },
      );

      // Return cleanup function to remove interceptors if apiClient updates
      return () => {
        apiClient.interceptors.request.eject(requestInterceptor);
        apiClient.interceptors.response.eject(responseInterceptor);
      };
    }, [apiClient]);

    switch (auth.activeNavigator) {
      case "signinSilent":
        return <div>Signing you in...</div>;
      case "signoutRedirect":
        return <div>Signing you out...</div>;
    }

    if (auth.isLoading) {
      return <div>Loading...</div>;
    }

    if (auth.error) {
      return <div>Oops... {auth.error.message}</div>;
    }

    if (auth.isAuthenticated) {
      if (auth.user) {
        accessTokenRef.current = auth.user.access_token
      }
      return <AppRouter />
    }

    return <button onClick={() => void auth.signinRedirect()}>Log in</button>;
}

