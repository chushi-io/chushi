<!DOCTYPE html>
<html>
    <head>
        <title>{{block "title" .}}{{end}}</title>
        <link href="/css/auth.css" rel="stylesheet" />
        <link href="https://unpkg.com/material-components-web@latest/dist/material-components-web.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
          <script src="https://unpkg.com/material-components-web@latest/dist/material-components-web.min.js"></script>
    </head>
    <body>
        <div class="container">
            {{block "authboss" .}}{{end}}
        </div>
    </body>
</html>
