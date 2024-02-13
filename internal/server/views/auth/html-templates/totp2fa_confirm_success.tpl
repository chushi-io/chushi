<div class="mdc-card-outlined">
    <h4>Authenticator two-factor enabled</h4>
    <p>
        <span>Recovery Codes:</span></br>
        {{range .recovery_codes -}}
        <span>{{.}}</span><br />
        {{end -}}
    </p>
</div>