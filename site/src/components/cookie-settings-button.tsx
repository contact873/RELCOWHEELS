"use client";

/** Reopens the consent banner from anywhere, including the cookies page. */
export function CookieSettingsButton() {
  return (
    <button
      type="button"
      className="btn btn-ghost"
      onClick={() => window.dispatchEvent(new Event("relwheels:cookie-settings"))}
    >
      Change my cookie choice
    </button>
  );
}
