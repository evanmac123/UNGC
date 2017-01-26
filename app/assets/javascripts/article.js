jQuery(document).ready(function() {
  var backToTopButton = jQuery('.back-to-top');

  if (backToTopButton.length > 0) {
    var offset = 250;
    var duration = 300;

    jQuery(window).scroll(function() {
      if (jQuery(this).scrollTop() > offset) {
        jQuery('.back-to-top').fadeIn(duration);
      } else {
        jQuery('.back-to-top').fadeOut(duration);
      }
    });

    jQuery('.back-to-top').click(function(event) {
      event.preventDefault();

      // scroll to the top
      jQuery('html, body').animate({scrollTop: 0}, duration);
      return false;
    });
  }

});
