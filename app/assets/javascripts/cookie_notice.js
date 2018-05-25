$(function() {

  function setCookie(key, value) {
    var expires = new Date();
    expires.setTime(expires.getTime() + (365 * 24 * 60 * 60 * 1000));
    document.cookie = key + '=' + value + ';path=/;expires=' + expires.toUTCString();
  }

  function getCookie(key) {
    var keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)');
    return keyValue ? keyValue[2] : null;
  }

  var cookieName = "ungc-accepted-cookie-terms";
  var hasAcceptedCookieTerms = getCookie(cookieName);
  var $dialog = $("#cookie-notice");

  if(!hasAcceptedCookieTerms) {
    $dialog.find('.close').on('click', function(e) {
      e.preventDefault();
      setCookie(cookieName, true);
      $dialog.remove();
    });

    $dialog.show();
  }

});
