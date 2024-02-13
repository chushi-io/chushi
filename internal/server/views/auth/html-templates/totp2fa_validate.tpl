<div class="mdc-card-outlined">
    <h4>Enter your authenticator code</h4>
    <form action="{{mountpathed "2fa/totp/validate"}}" method="POST">
    {{with .error}}{{.}}<br />{{end}}
    {{with .errors}}{{range .code}}<span>{{.}}</span><br />{{end}}{{end -}}
    <!-- Code Field -->
    <label class="mdc-text-field mdc-text-field--outlined">
          <span class="mdc-notched-outline">
            <span class="mdc-notched-outline__leading"></span>
            <span class="mdc-notched-outline__notch">
              <span class="mdc-floating-label" id="code-label">Code</span>
            </span>
            <span class="mdc-notched-outline__trailing"></span>
          </span>
        <input name="code" type="text" class="mdc-text-field__input" value="" autocomplete="off" aria-labelledby="code-label">
    </label>
    <!-- End Code -->

    <!-- Recovery Code Field -->
    <label class="mdc-text-field mdc-text-field--outlined">
          <span class="mdc-notched-outline">
            <span class="mdc-notched-outline__leading"></span>
            <span class="mdc-notched-outline__notch">
              <span class="mdc-floating-label" id="recovery-code-label">Recovery Code</span>
            </span>
            <span class="mdc-notched-outline__trailing"></span>
          </span>
        <input name="recovery_code" type="text" class="mdc-text-field__input" value="" autocomplete="off" aria-labelledby="recovery-code-label">
    </label>
    <!-- End Recovery Code -->
    {{with .csrf_token}}<input type="hidden" name="csrf_token" value="{{.}}" />{{end}}
    <div class="mdc-card__primary-action" tabindex="0">
        <button class="mdc-button foo-button" type="submit">
            <div class="mdc-button__ripple"></div>
            <span class="mdc-button__label">Submit</span>
        </button>
        <div class="mdc-card__ripple"></div>
    </div>
    </form>
</div>