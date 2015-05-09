$(function() {
  $('.tab').on('click', function() {
    $this = $(this);
    if ($this.hasClass('active')) {
      return;
    }
    if ($this.hasClass('events')) {
      $('.content.events').show();
      $('.content.news').hide();
      $this.toggleClass('active');
      $('.tab.news').toggleClass('active');
    } else if ($this.hasClass('news')) {
      $('.content.news').show();
      $('.content.events').hide();
      $this.toggleClass('active');
      $('.tab.events').toggleClass('active');
    }
  });
});
