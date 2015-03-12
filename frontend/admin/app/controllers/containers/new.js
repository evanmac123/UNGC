import Ember from 'ember';

export default Ember.Controller.extend({
  formTemplatePath: function() {
    var layout = this.get('model.container.layout');

    if (layout) {
      return `containers/new/${layout}`;
    } else {
      return null;
    }
  }.property('model.container.layout')
});
