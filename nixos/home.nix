{ pkgs, ... }:

{

  programs.git = {
    userName  = "Alderaeney";
    userEmail = "sariaaskort@tuta.io";
  };


  programs.firefox = {
    enable = true;
    profiles = {
      myprofile = {
        settings = {
          "gfx.webrender.all" = true;
          "media.hardwaremediakeys.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "media.ffmpeg.vaapi-drm-display.enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "privacy.firstparty.isolate" = true;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
          "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "geo.enabled" = false;
          "media.navigator.enabled" = false;
          "network.cookie.cookieBehavior" = 1;
          "network.dns.disablePrefetch" = true;
          "network.prefetch-next" = false;
          "webgl.disabled" = true;
          "dom.event.clipboardevents.enabled" = false;
          "browser.shell.checkDefaultBrowser" = false;
        };
      };
    };
  };

}
