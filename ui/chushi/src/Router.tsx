import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom";

const router = createBrowserRouter([
  {
    path: "/",
    element: <div>Hello world!</div>,
  },
  {
    path: "/organizations",
    element: <div>Hello from organizations</div>
  }
], {
  basename: "/app"
});

export default () => {
  return <RouterProvider router={router} />
}