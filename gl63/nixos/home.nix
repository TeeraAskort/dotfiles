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
          "gfx.font_rendering.cleartype_params.rendering_mode" = 5;
          "browser.display.auto_quality_min_font_size" = 1;
          "toolkit.telemetry.enabled" = false;
          "media.peerconnection.enabled" = false;
          "accessibility.typeaheadfind.flashBar" = 0;
          "accessibility.warn_on_browsewithcaret" = false;
          "beacon.enabled" = false;
          "browser.fixup.alternate.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.search.suggest.enabled" = false;
          "browser.sessionstore.warnOnQuit" = false;
          "browser.uidensity" = 1;
          "browser.urlbar.autoFill" = 1;
          "browser.urlbar.searchSuggestionsChoice" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.history.onlyTyped" = true;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.unifiedcomplete" = false;
          "camera.control.face_detection.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "device.sensors.enabled" = false;
          "geo.wifi.logging.enabled"  = false;
          "network.predictor.enabled" = false;
          "toolkit.telemetry.server" = "";
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
        };
      };
    };
  };

}
