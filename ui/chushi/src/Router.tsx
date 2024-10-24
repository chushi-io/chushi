import {createBrowserRouter, RouterProvider} from "react-router-dom";
import AppLayout from "./components/AppLayout.tsx";
import Organizations from "./pages/organizations/index";
import Organization from "./pages/organizations/show";
import Workspaces from "./pages/workspaces/index";
import Workspace from "./pages/workspaces/show";
import Runs from "./pages/runs/index";
import Run from "./pages/runs/show";

const router = createBrowserRouter([
  {
    path: "/",
    element: <AppLayout />,
    children: [{
      path: "organizations",
      children: [{
        path: "",
        element: <Organizations.Page />,
        loader: Organizations.Loader,
      }, {
        path: ":organizationName",
        element: <Organization.Page />,
        loader: Organization.Loader,
      }]
    }, {
      path: ":organizationName",
      children: [{
        path: "workspaces",
        element: <Workspaces.Page />,
        loader: Workspaces.Loader
      }, {
        path: ":workspaceName",
        children: [{
          path: "",
          loader: Workspace.Loader,
          element: <Workspace.Page />
        }, {
          path: "runs",
          loader: Runs.Loader,
          element: <Runs.Page />
        }, {
          path: "runs/:runId",
          loader: Run.Loader,
          element: <Run.Page />
        }]
      }]
    }]
  }
], {
  basename: "/app"
});

export default () => {
  return <RouterProvider router={router} />
}