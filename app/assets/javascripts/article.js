console.log('hello from article.js')

jQuery(document).ready(function() {
  // the DOM has settled and is ready.

  var backToTopButton = jQuery('.back-to-top');

  if (backToTopButton.length > 0) {
    console.log('we found a back-to-top button!');

    var offset = 250;
    var duration = 300;

    jQuery(window).scroll(function() {
      console.log( 'scrollllllllllling');
      if (jQuery(this).scrollTop() > offset) {
        console.log('at bottom');
        jQuery('.back-to-top').fadeIn(duration);
      } else {
        console.log('we are at the top');
        jQuery('.back-to-top').fadeOut(duration);
      }
    });

    jQuery('.back-to-top').click(function(event) {
      event.preventDefault();
      console.log('clicked');

      // scroll to the top
      jQuery('html, body').animate({scrollTop: 0}, duration);
      return false;
    });
  } else {
    console.log('booo, no back to top button');
  }

});
