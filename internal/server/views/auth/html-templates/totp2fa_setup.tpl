
<div class="mdc-card-outlined">

<form action="{{mountpathed "2fa/totp/setup"}}" method="post">
    {{with .csrf_token}}<input type="hidden" name="csrf_token" value="{{.}}" />{{end}}
	<div class="mdc-card__primary-action" tabindex="0">
        <button class="mdc-button foo-button" type="submit">
          <div class="mdc-button__ripple"></div>
          <span class="mdc-button__label">Start Setup</span>
        </button>
        <div class="mdc-card__ripple"></div>
      </div>
</form>
</div>