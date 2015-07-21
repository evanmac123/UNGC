import Ember from 'ember';

export default Ember.Component.extend({
  bindInputClickEvents: function() {
    var component = this;
    this.$('.image-url-input').on('click.x-list-component', function() {
      var $input = component.$(this);
      $input.focus();
      $input.select();
    });
  }.on('didInsertElement'),

  unbindInputClickEvents: function() {
    this.$('.image-url-input').off('click.x-list-component');
  }.on('willDestroyElement')
});
