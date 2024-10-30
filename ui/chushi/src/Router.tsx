import {createBrowserRouter, RouterProvider} from "react-router-dom";
import AppLayout from "./components/AppLayout.tsx";
import Organizations from "./pages/organizations/index";
import Organization from "./pages/organizations/show";
import NewOrganization from "./pages/organizations/new";
import Workspaces from "./pages/workspaces/index";
import Workspace from "./pages/workspaces/show";
import Runs from "./pages/runs/index";
import Run from "./pages/runs/show";
import Agents from "./pages/agents/index";
import Agent from "./pages/agents/show";
import NewAgent from "./pages/agents/new";
import Projects from "./pages/projects/index";
import Project from "./pages/projects/show";
import NewProject from "./pages/projects/new";
import RunTasks from "./pages/run-tasks/index";
import RunTask from "./pages/run-tasks/show";
import NewRunTask from "./pages/run-tasks/new";
import Policies from "./pages/policies/index";
import Policy from "./pages/policies/show";
import NewPolicy from "./pages/policies/new";

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
        path: "new",
        element: <NewOrganization.Page />,
        action: NewOrganization.Action,
      },{
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
        path: ":workspaceName/runs/:runId",
        loader: Run.Loader,
        element: <Run.Page />
      }, {
        path: "workspaces/:workspaceName",
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
      }, {
        path: "agent-pools",
        children: [{
          path: "",
          element: <Agents.Page />,
          loader: Agents.Loader
        }, {
          path: "new",
          element: <NewAgent.Page />,
          action: NewAgent.Action
        }, {
          path: ":agentPoolId",
          element: <Agent.Page />,
          loader: Agent.Loader
        }]
      }, {
        path: "projects",
        children: [{
          path: "",
          element: <Projects.Page />,
          loader: Projects.Loader
        }, {
          path: "new",
          element: <NewProject.Page />,
          action: NewProject.Action
        }, {
          path: ":projectId",
          element: <Project.Page />,
          loader: Project.Loader
        }]
      }, {
        path: "tasks",
        children: [{
          path: "",
          element: <RunTasks.Page />,
          loader: RunTasks.Loader
        }, {
          path: "new",
          element: <NewRunTask.Page />,
          action: NewRunTask.Action
        }, {
          path: ":runTaskId",
          element: <RunTask.Page />,
          loader: RunTask.Loader
        }]
      }, {
        path: "policies",
        children: [{
          path: "",
          element: <Policies.Page />,
          loader: Policies.Loader
        }, {
          path: "new",
          element: <NewPolicy.Page />,
          action: NewPolicy.Action
        }, {
          path: ":policyId",
          element: <Policy.Page />,
          loader: Policy.Loader
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