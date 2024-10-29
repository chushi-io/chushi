import {StrictMode, Suspense, useState} from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'

import { lazy } from 'react';
import {WebStorageStateStore} from "oidc-client-ts";
import axios from "axios";
import {Loader, MantineProvider} from "@mantine/core";

const App = lazy(() => import('./App.tsx'))
const AppLoader = () => {
  let [oidcConfig, setOidcConfig] = useState({})
  let [loaded, setLoaded] = useState(false)
  if (loaded) {
    return <Suspense fallback={<Loader color="blue" />}>
      <App oidcConfig={oidcConfig} />
    </Suspense>
  }

  // Load our OIDC config from the server. Due to the way React renders, this
  // needs to be loaded before our app is mounted, which has to be lazy loaded
  axios.get('/.well-known/app.json').then(res => {
    setOidcConfig({
      authority: res.data.authority,
      client_id: res.data.client,
      redirect_uri: res.data.redirect_uri,
      userStore: new WebStorageStateStore({ store: window.localStorage }),
    })
    setLoaded(true)
  })
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <MantineProvider>
      <AppLoader />
    </MantineProvider>
  </StrictMode>,
)


