<div class="row">
    <div class="col-3">
    <div class="mdc-card-outlined">
    <form action="{{mountpathed "register"}}" method="post">

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
          <input name="email" type="text" class="mdc-text-field__input" value="{{with .preserve}}{{with .email}}{{.}}{{end}}{{end}}" aria-labelledby="email-label">
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

        <!-- Password Field -->
        <label class="mdc-text-field mdc-text-field--outlined">
          <span class="mdc-notched-outline">
            <span class="mdc-notched-outline__leading"></span>
            <span class="mdc-notched-outline__notch">
              <span class="mdc-floating-label" id="email-label">Password</span>
            </span>
            <span class="mdc-notched-outline__trailing"></span>
          </span>
          <input type="password" name="password" class="mdc-text-field__input" value="{{with .preserve}}{{with .email}}{{.}}{{end}}{{end}}" aria-labelledby="email-label">
        </label>
        {{with .errors}}
            {{range .password}}
                <div class="mdc-text-field-helper-line">
                    <div class="mdc-text-field-helper-text" id="my-helper-id" aria-hidden="true">{{.}}</div>
                </div>
            {{end}}
        {{end -}}
        <br />
        <!-- End Password -->

        <!-- Confirm Password Field -->
        <label class="mdc-text-field mdc-text-field--outlined">
          <span class="mdc-notched-outline">
            <span class="mdc-notched-outline__leading"></span>
            <span class="mdc-notched-outline__notch">
              <span class="mdc-floating-label" id="email-label">Confirm Password</span>
            </span>
            <span class="mdc-notched-outline__trailing"></span>
          </span>
          <input type="password" name="confirm_password" class="mdc-text-field__input" value="{{with .preserve}}{{with .email}}{{.}}{{end}}{{end}}" aria-labelledby="email-label">
        </label>
        {{with .errors}}
            {{range .password}}
                <div class="mdc-text-field-helper-line">
                    <div class="mdc-text-field-helper-text" id="my-helper-id" aria-hidden="true">{{.}}</div>
                </div>
            {{end}}
        {{end -}}
        <!-- End Confirm Password -->
        <a href="/">Cancel</a>

        {{with .csrf_token}}<input type="hidden" name="csrf_token" value="{{.}}" />{{end}}
        <div class="mdc-card__primary-action" tabindex="0">
            <button class="mdc-button foo-button" type="submit">
                      <div class="mdc-button__ripple"></div>
                      <span class="mdc-button__label">Register</span>
                    </button>
            <div class="mdc-card__ripple"></div>
          </div>
    </form>
    </div>
  </div>
</div>