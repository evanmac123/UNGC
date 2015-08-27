$(function() {
  if($('.resource-links-list').length === 1) {
    $('.resource-link a').on('click',function(e){
      var id = $(this).data('resource-link-id');

      $.ajax({
        url: '/library/link_views',
        type: 'POST',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));},
        data: { resource_link_id: id }
      });
    });
  }
});
