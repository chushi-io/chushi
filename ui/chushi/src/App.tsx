import './App.css'
import '@mantine/core/styles.css';
import { MantineProvider } from '@mantine/core';
import {AuthProvider, useAuth} from "react-oidc-context";
import Router from "./Router.tsx";


// let oidcConfigLoaded = false
let oidcConfig = {
  authority: "https://caring-foxhound-whole.ngrok-free.app",
  client_id: "c-grvyKTI0gxf1SvvVoHs7hKGTmYoKDygEI7yiljdSM",
  redirect_uri: location.protocol + '//' + location.host + "/app"
}

export default function App() {
  return <MantineProvider>
    <AuthProvider {...oidcConfig}>
      <Main />
    </AuthProvider>
  </MantineProvider>
}

const Main = () => {
    const auth = useAuth();

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