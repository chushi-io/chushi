<div class="mdc-card-outlined">
    <h4>Authorize adding 2fa to your account</h4>
    <form action="{{ .url }}" method="post">
    {{with .errors}}{{with (index . "")}}{{range .}}<span>{{.}}</span><br />{{end}}{{end}}{{end -}}
    <!-- Email Field -->
    <label class="mdc-text-field mdc-text-field--outlined">
          <span class="mdc-notched-outline">
            <span class="mdc-notched-outline__leading"></span>
            <span class="mdc-notched-outline__notch">
              <span class="mdc-floating-label" id="email-label">Email</span>
            </span>
            <span class="mdc-notched-outline__trailing"></span>
          </span>
        <input name="code" type="text" disabled="true" class="mdc-text-field__input" value="{{.email}}" aria-labelledby="email-label">
    </label>
    {{with .errors}}
    {{range .email}}
    <div class="mdc-text-field-helper-line">
        <div class="mdc-text-field-helper-text" id="my-helper-id" aria-hidden="true">{{.}}</div>
    </div>
    {{end}}
    {{end -}}
    <br />
    <!-- End Email -->
    {{with .csrf_token}}<input type="hidden" name="csrf_token" value="{{.}}" />{{end}}
    <div class="mdc-card__primary-action" tabindex="0">
        <button class="mdc-button foo-button" type="submit">
            <div class="mdc-button__ripple"></div>
            <span class="mdc-button__label">OK</span>
        </button>
        <div class="mdc-card__ripple"></div>
    </div>
    </form>
</div>