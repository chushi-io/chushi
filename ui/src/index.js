import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';

import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';
import {createBrowserRouter, createRoutesFromElements, Route, RouterProvider} from "react-router-dom";

import Root from "./routes/Root";
import ListWorkspaces from "./routes/ListWorkspaces";
import ErrorPage from "./error-page";
import ShowWorkspace from "./routes/ShowWorkspace";
import ListAgents from "./routes/ListAgents";
import ShowAgent from "./routes/ShowAgent";

const router = createBrowserRouter(
    createRoutesFromElements(
        <Route path="/" element={<Root />} errorElement={<ErrorPage />}>
            <Route path="workspaces">
                <Route index={true} element={<ListWorkspaces />} />
                <Route path={":workspaceId"} element={<ShowWorkspace />} />
            </Route>
            <Route path={"agents"}>
                <Route index={true} element={<ListAgents />} />
                <Route path={":agentId"} element={<ShowAgent />} />
            </Route>
        </Route>
    ), {
        basename: "/ui"
    }
);

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
      <RouterProvider router={router} />
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
