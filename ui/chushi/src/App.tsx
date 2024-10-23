import './App.css'
import '@mantine/core/styles.css';
import { MantineProvider } from '@mantine/core';
import {AuthProvider, hasAuthParams, useAuth} from "react-oidc-context";
import Router from "./Router.tsx";
import {User, WebStorageStateStore} from "oidc-client-ts";
import {useEffect, useState} from "react";


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
      console.log(auth)
      return (
        <Router />
      );
    }

    return <button onClick={() => void auth.signinRedirect()}>Log in</button>;

}