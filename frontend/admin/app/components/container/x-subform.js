import Ember from 'ember';

export default Ember.Component.extend({
  subformTemplatePath: function() {
    var layout = this.get('record.layout');

    if (layout) {
      return `containers/_forms/${layout}`;
    } else {
      return null;
    }
  }.property('record.layout'),
});
